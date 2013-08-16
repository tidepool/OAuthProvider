module TidepoolAnalyze 
  module Formulator
    class ReactionTime2Formulator

      def initialize(input_data, formula)
        @reaction_times = input_data
        @formula = formula
      end

      # Input Data Format
      # [
      #   {
      #     test_type: 'simple',
      #     test_duration: @end_time - @start_time,
      #     average_time: average_time,
      #     slowest_time: slowest_time,
      #     fastest_time: fastest_time,
      #     total: total_shown,
      #     total_correct: correct,
      #     total_incorrect: incorrect,
      #     total_missed: missed
      #   },
      #   {
      #     test_type: 'complex',
      #     test_duration: @end_time - @start_time,
      #     average_time: average_time,
      #     slowest_time: slowest_time,
      #     fastest_time: fastest_time,
      #     total: total_shown,
      #     total_correct: correct,
      #     total_incorrect: incorrect,
      #     total_missed: missed
      #   }                
      # ]
      # Output Data Format
      # {
      #   average_time: average_time,
      #   average_time_simple: average_time_simple,
      #   average_time_complex: average_time_complex,
      #   fastest_time: fastest_time,
      #   slowest_time: slowest_time
      # }
      def calculate_result
        total_average_time = 0
        total_average_simple = 0
        total_average_complex = 0
        count_simple = 0
        count_complex = 0
        slowest_time = 0
        fastest_time = 100000
        count_all = 0

        @reaction_times.each do |entry|
          case entry[:test_type]
          when 'simple'
            total_average_simple += entry[:average_time]
            count_simple += 1
          when 'complex'
            total_average_complex += entry[:average_time]
            count_complex += 1
          end

          total_average_time += entry[:average_time]
          fastest_time = entry[:fastest_time] if entry[:fastest_time] < fastest_time
          slowest_time = entry[:slowest_time] if entry[:slowest_time] > slowest_time
          count_all += 1
        end

        average_time = total_average_time / count_all if count_all > 0
        average_time_simple = total_average_simple / count_simple if count_simple > 0
        average_time_complex = total_average_complex / count_complex if count_complex > 0
        {
          average_time: average_time,
          average_time_simple: average_time_simple,
          average_time_complex: average_time_complex,
          fastest_time: fastest_time,
          slowest_time: slowest_time,
          stage_data: @reaction_times
        }
      end   
    end
  end
end