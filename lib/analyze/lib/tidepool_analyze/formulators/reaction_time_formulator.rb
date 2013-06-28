require File.expand_path('../../utils/utils.rb', __FILE__)

module TidepoolAnalyze 
  module Formulator
    class ReactionTimeFormulator

      def initialize(input_data, formula)
        @reaction_times = input_data
        @formula = formula
      end

      # Input Data Format
      # [
      #   {
      #     test_type: 'simple',
      #     test_duration: 12220,
      #     correct_clicks_above_threshold: 3,
      #     clicks_above_threshold: 4,
      #     average_time_to_click: 257,
      #     min_time_to_click_above_threshold: 210,
      #     max_time_to_click_above_threshold: 340 
      #   },
      #   {
      #     test_type: 'complex',
      #     test_duration: 12220,
      #     correct_clicks_above_threshold: 3,
      #     clicks_above_threshold: 4,
      #     average_time_to_click: 257,
      #     min_time_to_click_above_threshold: 210,
      #     max_time_to_click_above_threshold: 340 
      #   }                
      # ]
      # Output Data Format
      # {
      #   total_average_time_zscore: total_average_time_zscore,
      #   total_average_time: total_average_time,
      #   min_time: min_time,
      #   max_time: min_time
      # }
      def calculate_result
        total_average_time = 0
        min_time = 100000
        max_time = 0
        count = 0
        @reaction_times.each do |entry|
          total_average_time += entry[:average_time_to_click]
          min_time = entry[:min_time_to_click_above_threshold] if entry[:min_time_to_click_above_threshold] < min_time
          max_time = entry[:max_time_to_click_above_threshold] if entry[:max_time_to_click_above_threshold] > max_time
          count += 1
        end
        values = @formula['average_simple_complex_reaction_time']

        # NOTE: We are asked to calculate the total_average_time, not the average of average_times
        # Z-score mean and std is in sec 
        total_average_time_zscore = TidepoolAnalyze::Utils::zscore(total_average_time/1000, values.mean, values.std)
        {
          total_average_time_zscore: total_average_time_zscore,
          total_average_time: total_average_time,
          average_time: total_average_time / count,
          min_time: min_time,
          max_time: max_time
        }
      end   
    end
  end
end