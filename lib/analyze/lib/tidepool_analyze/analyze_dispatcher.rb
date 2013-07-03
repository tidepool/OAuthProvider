Dir[File.expand_path('../utils/*.rb', __FILE__)].each {|file| require file }
Dir[File.expand_path('../analyzers/*.rb', __FILE__)].each {|file| require file }
Dir[File.expand_path('../formulators/*.rb', __FILE__)].each {|file| require file }
Dir[File.expand_path('../score_generators/*.rb', __FILE__)].each {|file| require file }
require 'csv'

module TidepoolAnalyze
  class AnalyzeDispatcher
    def initialize
    end

    def analyze(user_events, score_names)
      score_names_whitelist = { 
        big5: 'big5',
        holland6: 'holland6',
        emo: 'emo',
        reaction_time: 'reaction_time',
        capacity: 'capacity'
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

      if final_results.length > 0
        score = run_score_generator(score_name, final_results)
      end

      {
        final_results: final_results,
        score: score,
        version: '2.0'
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

    # def load_formula(formula_desc)
    #   formula_path = File.expand_path("../formula_sheets/#{formula_desc[:formula_sheet]}", __FILE__)
    #   formula_key = formula_desc[:formula_key].to_sym

    #   i = 0
    #   attributes = []
    #   types = []
    #   formula = {}
    #   CSV.foreach(formula_path) do |row|
    #     if i == 0
    #       # First row contains the attribute names 
    #       row.each do |value|
    #         attributes << value.to_sym
    #       end
    #     elsif i == 1
    #       # Second row contains the types
    #       row.each do |value|
    #         types << value.to_sym
    #       end
    #     else
    #       values = {}
    #       row.each_with_index do |value, index|
    #         case types[index]
    #         when :integer
    #           values[attributes[index]] = value.to_i
    #         when :float
    #           values[attributes[index]] = value.to_f
    #         when :string
    #           values[attributes[index]] = value
    #         else
    #           # Error case 
    #         end
    #       end
    #       formula[values[formula_key]] = ::OpenStruct.new(values)
    #     end
    #     i += 1
    #   end
    #   formula
    # end

    # # score_names expected are: :big5, :holland6, :reaction_time
    # def analyze(user_events, score_names)
    #   mini_games = events_by_mini_game(user_events)

    #   # Analyze events per module with their corresponding analyzer
    #   intermediate_results = intermediate_results(mini_games)

    #   # Aggregate results of all occurrences of each module
    #   aggregate_results = aggregate_results(intermediate_results)

    #   # Calculate the scores for a given set of score names
    #   scores = calculate_scores(aggregate_results, score_names)

    #   {
    #     :event_log => user_events,
    #     :intermediate_results => intermediate_results,
    #     :aggregate_results => aggregate_results,
    #     :scores => scores
    #   }
    # end


    # def events_by_mini_game(user_events)
    #   # Collect all events for each module
    #   mini_games = {}
    #   user_events.each do |user_event|
    #     mini_game = "#{user_event['module']}:#{user_event['stage']}"
    #     mini_games[mini_game] = [] unless mini_games.has_key?(mini_game)
    #     mini_games[mini_game] << user_event
    #   end  
    #   mini_games   
    # end

    # Intermediate Results:
    #
    # {
    #   :reaction_time => [
    #     {
    #       :stage => 0,
    #       :results => {
    #         :test_type => 'simple'
    #         :red => ...
    #       }
    #     },
    #   ],
    #   :image_rank => [
    #     {
    #       :stage => 3,
    #       :results => {
    #         :animal => 2,
    #         :adult => 4,
    #         ...
    #       }
    #     }
    #   ],
    #   :circles_test => {
    #   }
    # }
    # def intermediate_results(mini_games)
    #   intermediate_results = {}
    #   mini_games.each do |key, events|
    #     mini_game, stage = key.split(':')
    #     klass_name = "TidepoolAnalyze::Analyzer::#{mini_game.camelize}Analyzer"
    #     begin
    #       analyzer = klass_name.constantize.new(events)
    #       result = analyzer.calculate_result()
    #       intermediate_results[mini_game.to_sym] = [] if intermediate_results[mini_game.to_sym].nil?
    #       intermediate_results[mini_game.to_sym] << { stage: stage, results: result }
    #     rescue Exception => e
    #        raise e 
    #     end
    #   end
    #   intermediate_results
    # end

    # Aggregate Results:
    #
    # def aggregate_results(intermediate_results)
    #   aggregate_results = {}
    #   intermediate_results.each do |mini_game, results_across_stages|
    #     klass_name = "TidepoolAnalyze::Aggregator::#{mini_game.to_s.camelize}Aggregator"
    #     begin
    #       aggregator = klass_name.constantize.new(results_across_stages, @stages)
    #       aggregator.elements = @elements if aggregator.respond_to?(:elements)
    #       aggregator.circles = @circles if aggregator.respond_to?(:circles)
    #       aggregate_results[mini_game] = aggregator.calculate_result
    #     rescue Exception => e
    #       raise e
    #     end
    #   end
    #   aggregate_results
    # end

    # Calculate Scores:
    # {
    #  :big5 => { :big5_dimension => "High Openness", 
    #             :big5_scores => [ :conscientiousness => .34, :openness => .1, ...
    #             ]},
    #  :holland6 => ...
    # }

    # def calculate_scores(aggregate_results, score_names)
    #   scores = {}
    #   score_names.each do |score_name|
    #     klass_name = "TidepoolAnalyze::ScoreGenerator::#{score_name.to_s.camelize}Score"
    #     begin
    #       score_generator = klass_name.constantize.new()
    #       score = score_generator.calculate_score(aggregate_results)
    #       scores[score_name.to_sym] = score
    #     rescue Exception => e
    #       raise e
    #     end
    #   end
    #   scores
    # end
  end
end
