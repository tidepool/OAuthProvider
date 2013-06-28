module TidepoolAnalyze
  module ScoreGenerator
    class CapacityScore 
      def calculate_score(input_data)
        output = {}
        input_data.each do | result |
          if result.has_key?(:demand)
            # Currently we are ignoring any of the reaction time results from the user
            # The score is merely the output of the corrected demand survey.
            # The correction coefficient of demand survey takes into account the
            # results of other participants' reaction time results. 
            output = result
          end
        end
        output 
      end
    end
  end
end