Dir[File.expand_path('../utils/*.rb', __FILE__)].each {|file| require file }
Dir[File.expand_path('../analyzers/*.rb', __FILE__)].each {|file| require file }
Dir[File.expand_path('../formulators/*.rb', __FILE__)].each {|file| require file }
Dir[File.expand_path('../score_generators/*.rb', __FILE__)].each {|file| require file }
require 'csv'

module TidepoolAnalyze
  class AnalyzeDispatcher
    def initialize
    end

    # Output Format:
    # {
    #   score_name1: {
    #     final_results: []
    #     score: {}
    #   },
    #   score_name2: {
    #     ...
    #   },
    #   ...
    # }
    def analyze(user_events, score_names)
      score_names_whitelist = { 
        big5: 'big5',
        holland6: 'holland6',
        holland6_new: 'holland6_new',
        emo: 'emo',
        reaction_time: 'reaction_time',
        capacity: 'capacity',
        survey: 'survey'
      }
      mini_game_events = events_by_mini_game(user_events)

      analysis = {}
      score_names.each do |score_name|
        # Load the recipe for the score
        if score_names_whitelist[score_name.to_sym]
          recipe = read_recipe score_name
          analysis[score_name.to_sym] = execute_recipe recipe, score_name, mini_game_events
        end
      end
      analysis
    end

    def events_by_mini_game(user_events)
      mini_game_events = {}
      user_events.each do |user_event|
        mini_game = user_event['module']
        stage = user_event['stage']
        mini_game_events[mini_game] = {} unless mini_game_events.has_key?(mini_game)
        mini_game_events[mini_game][stage] = [] unless mini_game_events[mini_game].has_key?(stage)
        mini_game_events[mini_game][stage] << user_event
      end
      mini_game_events
    end

    def read_recipe(score_name)
      recipe_json = IO.read(File.expand_path("../recipes/#{score_name}_recipe.json", __FILE__))
      recipe = JSON.parse(recipe_json, symbolize_names: true)
    end

    def execute_recipe(recipe, score_name, mini_game_events)
      final_results = [] 
      recipe.each do |step|
        results = nil

        if step[:score_generator]
          # This allows me to override the score generator name
          score_name = step[:score_generator]
        else
          if step[:formula_sheet].nil? || step[:formula_key].nil? 
            formula_desc = nil
          else
            formula_desc = {
              formula_sheet: step[:formula_sheet],
              formula_key: step[:formula_key]
            }
          end

          formula = TidepoolAnalyze::Utils::load_formula(formula_desc)

          if step[:analyzer] && !step[:analyzer].empty?
            input_data = mini_game_events[step[:user_event_source]]
            # Analyzers will be called for each stage of the game with subset
            # of the user_events for that stage only
            results = run_analyzer(step[:analyzer], formula, input_data)
          end

          if step[:formulator] && !step[:formulator].empty? && results && !results.empty?
            final_results << run_formulator(step[:formulator], formula, results)
          end
        end
      end

      if final_results.length > 0
        score = run_score_generator(score_name, final_results)
      end

      {
        final_results: final_results,
        score: score
      }
    end

    # Input:
    #   analyzer_class: The class name for the Analyzer without the namespace 
    #   input_data: User events for the specific mini game for all levels
    #
    # Output:
    #   results: Analyzed results from the mini game, divided up by level
    #   The result format depends on the Analyzer
    #   The Formulator is expected to understand this result format
    #   [
    #     result1,
    #     result2,
    #     ...
    #   ]
    def run_analyzer(analyzer_class, formula, input_data)
      klass_name = "TidepoolAnalyze::Analyzer::#{analyzer_class}"
      results = []
      return results if input_data.nil?

      input_data.each do |stage, data|
        analyzer = klass_name.constantize.new(data, formula)
        result = analyzer.calculate_result
        if result.length > 0 
          results << result 
        end
      end
      results
    end

    # Input: 
    #   formulator_class: The class name for the Formulator without the namespace
    #   formula_desc:
    #     {
    #       formula_sheet: Name of the csv file without the path info
    #       formula_key: Name of the attribute to be used as a key
    #     }
    #   input_data: The results from the Analyzer. It needs to be in the following
    #   general form, but the actual result format will depend on the Analyzer & Formulator
    #   implicit contract.
    #   [
    #     result1,
    #     result2,
    #     ...
    #   ]
    # Output:
    #   results: An array of results. The actual result format will depend on the implicit
    #   contract between the Formulator and ScoreGenerator
    #   [
    #     result1,
    #     result2
    #   ]
    def run_formulator(formulator_class, formula, input_data)
      klass_name = "TidepoolAnalyze::Formulator::#{formulator_class}"

      formulator = klass_name.constantize.new(input_data, formula)
      results = formulator.calculate_result
    end

    # Input:
    #   score_name: The name of the score to be calculated (such as big5, holland6 etc.)
    #   input_data: The results calculated by the formulator. The actual result format
    #   will be part of the implicit contract between the Formulator & ScoreGenerator.
    #   It is expected to be an array of results:
    #   [
    #     result1,
    #     result2
    #   ]
    # Output:
    #   result: A result that describes the final calculation of a given score_name. The format 
    #   depends on the score type (big5, holland6, emo ...)
    def run_score_generator(score_name, input_data)
      klass_name = "TidepoolAnalyze::ScoreGenerator::#{score_name.to_s.camelize}Score"

      score_generator = klass_name.constantize.new()
      score = score_generator.calculate_score(input_data)
    end

  end
end
