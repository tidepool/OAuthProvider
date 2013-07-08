require File.expand_path('../../utils/utils.rb', __FILE__)

module TidepoolAnalyze 
  module Formulator
    class EmoFormulator

      # Input Data Format
      # [
      #     {
      #       :trait1 => "boredom",
      #       :size => 3,
      #       :distance_standard => 2,
      #       :overlap => 0.34, 
      #       :maps_to => 'factor5'
      #     },
      #     {
      #       :trait1 => "anger",
      #       :size => 3,
      #       :distance_standard => 2,
      #       :overlap => 0.34, 
      #       :maps_to => 'factor2'
      #     },
      #     ...
      # ]

      # Output Data Format
      # {
      #   factors:
      #     {
      #       factor1 : {
      #         weighted_total: 4,
      #         average: 1.2,
      #         count: 3,
      #         average_zscore: -1.3,
      #         mean: 1.2,
      #         std: 1
      #       },
      #       ...
      #     },
      #   furthest_emotion:
      #     {
      #       emotion: "anger"
      #       distance_standard: 1.8
      #     },
      #   closest_emotion:
      #     {
      #       emotion: "boredom"
      #       distance_standard: 1.2
      #     }
      # }
      def initialize(input_data, formula)  
        @raw_results = TidepoolAnalyze::Utils::merge_across_stages(input_data)
        @circles = formula
      end

      def calculate_result
        max_distance_standard, max_emotion = calculate_max_distance_standard(@raw_results)
        min_distance_standard, min_emotion = calculate_min_distance_standard(@raw_results)

        aggregate_weighted_total = {}
        @raw_results.each do |result|
          emo_name = result[:trait1]
          circle = @circles[emo_name]
          if circle && circle.std && circle.mean
            maps_to = circle.maps_to.downcase.to_sym
            if aggregate_weighted_total[maps_to].nil?
              aggregate_weighted_total[maps_to] = { weighted_total: 0, count: 0 }
            end
            if emo_name.to_sym == :boredom
              value = max_distance_standard - result[:distance_standard]
            else
              value = result[:distance_standard]
            end
            aggregate_weighted_total[maps_to][:weighted_total] += value
            aggregate_weighted_total[maps_to][:count] += 1
            aggregate_weighted_total[maps_to][:mean] = circle.mean # Mean is the same for all maps_to factors
            aggregate_weighted_total[maps_to][:std] = circle.std # Std is the same for all maps_to factors            
          end
        end

        aggregate_weighted_total.each do |maps_to, value|
          value[:average] = value[:weighted_total] / value[:count] if value[:count] != 0
          value[:average_zscore] = TidepoolAnalyze::Utils::zscore(value[:average], value[:mean], value[:std])
        end
        {
          factors: aggregate_weighted_total,
          furthest_emotion: {
            emotion: max_emotion,
            distance_standard: max_distance_standard
          },
          closest_emotion: {
            emotion: min_emotion,
            distance_standard: min_distance_standard
          }
        }
      end

      def calculate_max_distance_standard(input)
        max_distance_standard = 0
        max_emo = ""
        input.each do | circle |
          if circle[:distance_standard] > max_distance_standard
            max_distance_standard = circle[:distance_standard]
            max_emo = circle[:trait1]
          end
        end
        return max_distance_standard, max_emo
      end

      def calculate_min_distance_standard(input)
        min_distance_standard = 100000
        min_emo = ""
        input.each do | circle |
          if circle[:distance_standard] < min_distance_standard
            min_distance_standard = circle[:distance_standard]
            min_emo = circle[:trait1]
          end
        end
        return min_distance_standard, min_emo
      end
    end
  end
end
