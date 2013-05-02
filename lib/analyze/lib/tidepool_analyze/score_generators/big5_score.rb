module TidepoolAnalyze
  module ScoreGenerator
    class Big5Score
      def calculate_score(aggregate_results)
        big5_scores = {
            openness: 0,
            agreeableness: 0,
            conscientiousness: 0,
            extraversion: 0,
            neuroticism: 0
        }

        # Aggregate all Big5 values across modules
        count = 0
        aggregate_results.each do | module_name, result |
          if result && result[:big5]
            count += 1
            result[:big5].each do |dimension, value|
              big5_scores[dimension] += value[:average] if big5_scores[dimension]
            end
          end
        end

        # Now average each dimension:
        big5_scores.each do |dimension, value| 
          big5_scores[dimension] = value / count if count > 0
        end

        # Find the average value across all dimensions
        total_big5 = big5_scores.values.reduce(:+)
        average_big5 = total_big5 / 5

        # Find the highest valued Big5 Dimension
        high_big5_value = 0
        high_big5_dimension = :openness
        big5_scores.each do |dimension, value|
          if value > high_big5_value
            high_big5_dimension = dimension
            high_big5_value = value
          end
        end

        # Find the lowest valued Big5 Dimension
        low_big5_value = 100000
        low_big5_dimension = :openness
        big5_scores.each do |dimension, value|
          if value < low_big5_value
            low_big5_dimension = dimension
            low_big5_value = value
          end
        end

        # Pick either the lowest or the highest values depending on its absolute difference from average
        final_score = (high_big5_value - average_big5).abs > (low_big5_value - average_big5).abs ? "high_#{high_big5_dimension.to_s}" : "low_#{low_big5_dimension.to_s}"
        {
          friendly_name: 'Personality - Big5',
          dimension: final_score,
          score: big5_scores
        }
      end
    end
  end
end