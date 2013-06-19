module TidepoolAnalyze 
  module Aggregator
    class ReactionTimeAggregator
      def initialize(raw_results, stages)
        @raw_results = raw_results
        @stages = stages
      end

      # Raw results are coming in:
      #[
      #  {
      #    stage => 2,
      #    results =>
      #      {
      #         :test_type => 'simple' || 'complex',
      #         :test_duration  => 12220,
      #         :red => {
      #                   :total_clicks_with_threshold => 3,
      #                   :total_clicks => 5,
      #                   :average_time_with_threshold => 1230,
      #                   :average_time => 232,
      #                   :total_correct_clicks_with_threshold => 2,
      #                   :average_correct_time_to_click => 1
      #                 },
      #         :green => {
      #                 }
      #      }
      #  },
      #  {
      #  }
      #]
      #
      # The output is:
      # {
      #    :red => {
      #             :total_clicks_with_threshold => 3,
      #             :total_clicks => 5,
      #             :average_time_with_threshold => 1230,
      #             :average_time => 232,
      #             :total_correct_clicks_with_threshold => 2,
      #             :average_correct_time_to_click => 1
      #       }
      # }
      def calculate_result
        results_across_stages = flatten_stages_to_results
        agg_result = {}
        # Only looking at :red color
        colors = [:red]
        results_across_stages.each do |result|
          colors.each do |color|
            timings = result[color]
            if timings
              agg_result[color] ||= {
                  :total_clicks_with_threshold => 0,
                  :total_clicks => 0,
                  :total_correct_clicks_with_threshold => 0,
                  :average_time => 0,
                  :average_time_with_threshold => 0,
                  :average_correct_time_to_click => 0,
                  :at_results => 0,
                  :atwt_results => 0,
                  :actc_results => 0
              }
              agg_result[color][:total_clicks] += timings[:total_clicks] unless timings[:total_clicks].nil?
              agg_result[color][:total_clicks_with_threshold] += timings[:total_clicks_with_threshold] unless timings[:total_clicks_with_threshold].nil?
              agg_result[color][:total_correct_clicks_with_threshold] += timings[:total_correct_clicks_with_threshold] unless timings[:total_correct_clicks_with_threshold].nil?
              agg_result[color][:average_time] += timings[:average_time] unless timings[:average_time].nil?
              agg_result[color][:at_results] += 1 unless timings[:average_time].nil?
              agg_result[color][:average_time_with_threshold] += timings[:average_time_with_threshold] unless timings[:average_time_with_threshold].nil?
              agg_result[color][:atwt_results] += 1 unless timings[:average_time_with_threshold].nil?
              agg_result[color][:average_correct_time_to_click] += timings[:average_correct_time_to_click] unless timings[:average_correct_time_to_click].nil?
              agg_result[color][:actc_results] += 1 unless timings[:average_correct_time_to_click].nil?
            end
          end
        end
        num_of_results = results_across_stages.length
        if num_of_results != 0
          colors.each do |color|
            if agg_result[color]
              agg_result[color][:average_time] = agg_result[color][:average_time] / agg_result[color][:at_results]
              agg_result[color][:average_time_with_threshold] = agg_result[color][:average_time_with_threshold] / agg_result[color][:atwt_results]
              agg_result[color][:average_correct_time_to_click] = agg_result[color][:average_correct_time_to_click] / agg_result[color][:actc_results]
            end
          end
        end
        agg_result
      end

      def flatten_stages_to_results
        @raw_results.map { |entry| entry[:results] }
      end
    end
  end
end