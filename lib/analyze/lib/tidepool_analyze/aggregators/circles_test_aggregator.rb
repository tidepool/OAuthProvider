module TidepoolAnalyze 
  module Aggregator
    class CirclesTestAggregator
      attr_accessor :circles, :raw_results, :stages

      def initialize(raw_results, stages)
        @raw_results = raw_results
        @stages = stages
        @circles = {}
      end

      def break_into_assessment_types
        raw_results_by_type = {}
        @raw_results.each do |entry|
          stage_no = entry[:stage].to_i
          assessment_type = @stages[stage_no][:assessment_type.to_s].downcase
          raw_results_by_type[assessment_type.to_sym] = [] if raw_results_by_type[assessment_type.to_sym].nil?
          raw_results_by_type[assessment_type.to_sym] |= entry[:results]
        end
        raw_results_by_type
      end

      # The final result is in the form of:
      # {
      #   :big5 => {
      #       :openness => {:weighted_total => num, :count => count, :average => average },
      #       :agreeableness => {:weighted_total => num, :count => count, :average => average }
      #    },
      #   :holland6 => {
      #    }
      # }

      def calculate_result
        raw_results_by_type = break_into_assessment_types
        final_results = {}
        raw_results_by_type.each do |assessment_type, raw_results|
          final_results[assessment_type] = result_by_assessment_type(raw_results)
        end
        final_results
      end

      # The raw results are expected in the form of:
      # [
      #   {
      #     :trait1 => "Sociable",
      #     :trait2 => "Adventurous",
      #     :size => 3,
      #     :distance_rank => 2,
      #     :overlap => 0.34
      #   },
      #   ...
      # ]
      # Algorithm:
      # 1. Calculate the z-scores for each of size, distance and overlap
      # 2. Each name_pair (trait1/trait2) maps to an attribute of the assessment type (E.g. Openness for Big5)
      # 3. Multiply the z-scores by corresponding weights
      # 4. Add the weighted z-scores per attribute of assessment type.
      # 5. Average the weighted z-scores
      # The output is in the form of:
      # {
      #   :openness => {:weighted_total => num, :count => count, :average => average },
      #   :agreeableness => {:weighted_total => num, :count => count, :average => average }
      # }

      def result_by_assessment_type(raw_results)
        aggregate_weighted_total = {}
        raw_results.each do |result|
          name_pair = "#{result[:trait1]}/#{result[:trait2]}"
          circle = @circles[name_pair]
          if !circle.nil? && circle.size_sd != 0 && circle.distance_sd != 0 && circle.overlap_sd != 0
            size_zscore, distance_zscore, overlap_zscore =
                calculate_zscores(result[:size], result[:distance_rank], result[:overlap], circle)

            weighted_total =  size_zscore * circle.size_weight +
                distance_zscore * circle.distance_weight +
                overlap_zscore * circle.overlap_weight

            maps_to = circle.maps_to.downcase.to_sym
            if aggregate_weighted_total[maps_to].nil?
              aggregate_weighted_total[maps_to] = { weighted_total: 0, count: 0 }
            end
            aggregate_weighted_total[maps_to][:weighted_total] += weighted_total
            aggregate_weighted_total[maps_to][:count] += 1
          end
        end
        aggregate_weighted_total.each do |maps_to, value|
          value[:average] = value[:weighted_total] / value[:count] if value[:count] != 0
        end
        aggregate_weighted_total
      end

      # zscores will be 0 if the standard deviation is zero or there is no value in database
      def calculate_zscores(size, distance_rank, overlap, circle)
        return 0.0, 0.0, 0.0 if circle.nil?

        size_zscore = zscore(size, circle.size_mean, circle.size_sd)
        distance_zscore = zscore(distance_rank, circle.distance_mean, circle.distance_sd)

        # Circle overlaps are stored in % in the db, convert to 0..1
        overlap_mean = circle.overlap_mean / 100
        overlap_sd = circle.overlap_sd / 100
        overlap_zscore = zscore(overlap, overlap_mean, overlap_sd)

        return size_zscore, distance_zscore, overlap_zscore
      end

      # See for definition: http://en.wikipedia.org/wiki/Standard_score
      def zscore(value, mean, sd)
        return 0.0 if sd == 0
        (value - mean) / sd
      end
    end
  end
end