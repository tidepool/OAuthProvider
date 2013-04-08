Dir[File.expand_path('../analyzers/*.rb', __FILE__)].each {|file| require file }
Dir[File.expand_path('../aggregators/*.rb', __FILE__)].each {|file| require file }

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

    def analyze(user_events)
      modules = sort_events_to_modules(user_events)

      # Analyze events per module with their corresponding analyzer
      raw_results = raw_results(modules)

      # Aggregate results of all occurrences of each module
      aggregate_results = aggregate_results(raw_results)

      # Calculate the Big5, Holland6 and Emo8 dimensions
      big5_score = calculate_big5(aggregate_results)
      holland6_score = calculate_holland6(aggregate_results)

      {
        :raw_results => raw_results,
        :aggregate_results => aggregate_results,
        :big5_score => big5_score,
        :holland6_score => holland6_score
      }
    end

    def calculate_big5(aggregate_results)
      big5_scores = {
          Openness: 0,
          Agreeableness: 0,
          Conscientiousness: 0,
          Extraversion: 0,
          Neuroticism: 0
      }

      # Aggregate all Big5 values across modules
      aggregate_results.each do | module_name, result |
        if result && result[:Big5]
          result[:Big5].each do |dimension, value|
            big5_scores[dimension] += value[:average]
          end
        end
      end

      # Find the average value across all dimensions
      total_big5 = big5_scores.values.reduce(:+)
      average_big5 = total_big5 / 5

      # Find the highest valued Big5 Dimension
      high_big5_value = 0
      high_big5_dimension = :Openness
      big5_scores.each do |dimension, value|
        if value > high_big5_value
          high_big5_dimension = dimension
          high_big5_value = value
        end
      end

      # Find the lowest valued Big5 Dimension
      low_big5_value = 100000
      low_big5_dimension = :Openness
      big5_scores.each do |dimension, value|
        if value < low_big5_value
          low_big5_dimension = dimension
          low_big5_value = value
        end
      end

      # Pick either the lowest or the highest values depending on its absolute difference from average
      (high_big5_value - average_big5).abs > (low_big5_value - average_big5).abs ? "High #{high_big5_dimension.to_s}" : "Low #{low_big5_dimension.to_s}"
    end

    def calculate_holland6(aggregate_results)
      # Holland6 comes from the Circles_Test modules
      holland6_scores = {
          Realistic: 0,
          Artistic: 0,
          Social: 0,
          Enterprising: 0,
          Investigative: 0,
          Conventional: 0
      }
      aggregate_results.each do | module_name, result |
        if result && result[:Holland6]
          result[:Holland6].each do |dimension, value|
            holland6_scores[dimension] += value[:average]
          end
        end
      end
      holland6_value = 0
      holland6_dimension = :Realistic
      holland6_scores.each do |dimension, value|
        if value > holland6_value
          holland6_dimension = dimension
          holland6_value = value
        end
      end
      "#{holland6_dimension.to_s}"
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

    # Raw Results:
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
    def raw_results(modules)
      raw_results = {}
      modules.each do |key, events|
        module_name, stage = key.split(':')
        klass_name = "TidepoolAnalyze::Analyzer::#{module_name.camelize}Analyzer"
        begin
          analyzer = klass_name.constantize.new(events)
          result = analyzer.calculate_result()
          raw_results[module_name.to_sym] = [] if raw_results[module_name.to_sym].nil?
          raw_results[module_name.to_sym] << { stage: stage, results: result }
        rescue Exception => e
           raise e 
        end
      end
      raw_results
    end


    # Aggregate Results:
    #
    def aggregate_results(raw_results)
      aggregate_results = {}
      raw_results.each do |module_name, results_across_stages|
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
  end
end
