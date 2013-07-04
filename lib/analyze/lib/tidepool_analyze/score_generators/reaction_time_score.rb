module TidepoolAnalyze
  module ScoreGenerator
    class ReactionTimeScore
      def calculate_score(input_data)
        return {} if input_data.class.to_s != 'Array' || input_data.length == 0

        output = {}
        input_data.each do | data |
          # For now assume that only take into account the speed results from reaction_time test
          # The demand calculation from the survey stage is not being used.
          # This will ignore 
          # { demand: demand } 
          # final result
          if data[:average_time] 
            output = {
              fastest_time: data[:min_time],
              slowest_time: data[:max_time],
              average_time: data[:average_time] 
            }
          end
        end
        output
      end
    end
  end
end
