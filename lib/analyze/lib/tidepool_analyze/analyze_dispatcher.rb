Dir[File.expand_path('../analyzers/*.rb', __FILE__)].each {|file| require file }
Dir[File.expand_path('../aggregators/*.rb', __FILE__)].each {|file| require file }
Dir[File.expand_path('../score_generators/*.rb', __FILE__)].each {|file| require file }

module TidepoolAnalyze
  class AnalyzeDispatcher
    def initialize(stages, elements, circles)
      # TODO: Remove dependency to stages, only used by CirclesTestAggregator.
      #       Needs to record the assessment_type in the user events.
      @stages = stages
      @elements = elements
      @circles = circles
      @current_analysis_version = '1.0'
    end

    # score_names expected are: :big5, :holland6, :reaction_time
    def analyze(user_events, score_names)
      modules = sort_events_to_modules(user_events)

      # Analyze events per module with their corresponding analyzer
      intermediate_results = intermediate_results(modules)

      # Aggregate results of all occurrences of each module
      aggregate_results = aggregate_results(intermediate_results)

      # Calculate the scores for a given set of score names
      scores = calculate_scores(aggregate_results, score_names)

      {
        :event_log => user_events,
        :intermediate_results => intermediate_results,
        :aggregate_results => aggregate_results,
        :scores => scores
      }
    end

    def sort_events_to_modules(user_events)
      # Collect all events for each module
      modules = {}
      user_events.each do |user_event|
        module_name = "#{user_event['module']}:#{user_event['stage']}"
        modules[module_name] = [] unless modules.has_key?(module_name)
        modules[module_name] << user_event
      end  
      modules   
    end

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
    def intermediate_results(modules)
      intermediate_results = {}
      modules.each do |key, events|
        module_name, stage = key.split(':')
        klass_name = "TidepoolAnalyze::Analyzer::#{module_name.camelize}Analyzer"
        begin
          analyzer = klass_name.constantize.new(events)
          result = analyzer.calculate_result()
          intermediate_results[module_name.to_sym] = [] if intermediate_results[module_name.to_sym].nil?
          intermediate_results[module_name.to_sym] << { stage: stage, results: result }
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
      intermediate_results.each do |module_name, results_across_stages|
        puts "Raw Result = #{results_across_stages}"
        klass_name = "TidepoolAnalyze::Aggregator::#{module_name.to_s.camelize}Aggregator"
        begin
          aggregator = klass_name.constantize.new(results_across_stages, @stages)
          aggregator.elements = @elements if aggregator.respond_to?(:elements)
          aggregator.circles = @circles if aggregator.respond_to?(:circles)
          aggregate_results[module_name] = aggregator.calculate_result
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
