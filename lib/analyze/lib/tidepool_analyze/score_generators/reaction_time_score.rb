module TidepoolAnalyze
  module ScoreGenerator
    class ReactionTimeScore
      def calculate_score(input_data)
        return {} if input_data.class.to_s != 'Array' || input_data.length == 0

        # For now assume that there is only one result coming from ReactionTimeFormulator
        {
          fastest_time: input_data[0][:min_time],
          slowest_time: input_data[0][:max_time],
          average_time: input_data[0][:average_time]
        }
      end
    end
  end
end
