Dir[File.expand_path('../analyzers/*.rb', __FILE__)].each {|file| require file }
Dir[File.expand_path('../aggregators/*.rb', __FILE__)].each {|file| require file }
Dir[File.expand_path('../score_generators/*.rb', __FILE__)].each {|file| require file }

module TidepoolAnalyze
  class AnalyzeDispatcher
    def initialize(stages, elements, circles)
      # TODO: Remove dependency to stages, only used by CirclesTestAggregator.
      #       Needs to record the game_type in the user events.
      @stages = stages
      @elements = elements
      @circles = circles
    end

    def analyze(user_events, score_names)
      score_names_whitelist = { 
        big5: 'big5',
        holland6: 'holland6',
        emo: 'emo',
        reaction: 'reaction'
      }
      mini_game_events = events_by_mini_game(user_events)

      score_names.each do |score_name|
        # Load the recipe for the score
        scores = {}
        if score_names_whitelist[score_name.to_sym]
          recipe_json = IO.read(File.expand_path("../recipes/#{score_name}_recipe.json", __FILE__))
          recipe = JSON.parse(recipe_json, symbolize_names: true)
          klass_name = "TidepoolAnalyze::ScoreGenerator::#{score_name.to_s.camelize}Score"
          
          begin
            score_generator = klass_name.constantize.new()
            score = score_generator.generate(mini_game_events, recipe)
            scores[score_name.to_sym] = score
          rescue Exception => e
            raise e
          end
        end
        scores
      end
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
    end



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
    def intermediate_results(mini_games)
      intermediate_results = {}
      mini_games.each do |key, events|
        mini_game, stage = key.split(':')
        klass_name = "TidepoolAnalyze::Analyzer::#{mini_game.camelize}Analyzer"
        begin
          analyzer = klass_name.constantize.new(events)
          result = analyzer.calculate_result()
          intermediate_results[mini_game.to_sym] = [] if intermediate_results[mini_game.to_sym].nil?
          intermediate_results[mini_game.to_sym] << { stage: stage, results: result }
        rescue Exception => e
           raise e 
        end
      end
      intermediate_results
    end

    # Aggregate Results:
    #
    def aggregate_results(intermediate_results)
      aggregate_results = {}
      intermediate_results.each do |mini_game, results_across_stages|
        klass_name = "TidepoolAnalyze::Aggregator::#{mini_game.to_s.camelize}Aggregator"
        begin
          aggregator = klass_name.constantize.new(results_across_stages, @stages)
          aggregator.elements = @elements if aggregator.respond_to?(:elements)
          aggregator.circles = @circles if aggregator.respond_to?(:circles)
          aggregate_results[mini_game] = aggregator.calculate_result
        rescue Exception => e
          raise e
        end
      end
      aggregate_results
    end

    # Calculate Scores:
    # {
    #  :big5 => { :big5_dimension => "High Openness", 
    #             :big5_scores => [ :conscientiousness => .34, :openness => .1, ...
    #             ]},
    #  :holland6 => ...
    # }

    def calculate_scores(aggregate_results, score_names)
      scores = {}
      score_names.each do |score_name|
        klass_name = "TidepoolAnalyze::ScoreGenerator::#{score_name.to_s.camelize}Score"
        begin
          score_generator = klass_name.constantize.new()
          score = score_generator.calculate_score(aggregate_results)
          scores[score_name.to_sym] = score
        rescue Exception => e
          raise e
        end
      end
      scores
    end
  end
end
