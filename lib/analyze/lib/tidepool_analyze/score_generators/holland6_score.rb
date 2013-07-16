module TidepoolAnalyze
  module ScoreGenerator
    class Holland6Score
      def calculate_score(input_data)
        return {} if input_data.class.to_s != 'Array'
        # Holland6 comes from the Circles_Test modules
        holland6_scores = {
            realistic: 0,
            artistic: 0,
            social: 0,
            enterprising: 0,
            investigative: 0,
            conventional: 0
        }
        count = 0
        input_data.each do | result |
          if result && result.has_key?(:realistic)
            count += 1
            result.each do |dimension, value|
              holland6_scores[dimension] += value[:average] if holland6_scores[dimension]
            end
          end
        end

        # Now average each dimension:
        holland6_scores.each do |dimension, value| 
          holland6_scores[dimension] = value / count if count > 0
        end

        # Find the highest valued Holland6 Dimension
        holland6_value = -100000
        holland6_dimension = :realistic
        holland6_scores.each do |dimension, value|
          if value > holland6_value
            holland6_dimension = dimension
            holland6_value = value
          end
        end

        # Find the lowest valued Holland6 Dimension
        min_holland6_value = 100000
        holland6_scores.each do |dimension, value|
          min_holland6_value = value if value < min_holland6_value
        end

        # Adjust the numbers so that the holland6 scores are distributed >= (1 * 10) 
        # 1. Pick the min value
        # 2. Add abs(min_value) + 1 to all values 
        # 3. Multiply all values by 10      
        adjust_by = min_holland6_value.abs + 1
        holland6_scores.each do |dimension, value|
          holland6_scores[dimension] = (value + adjust_by) * 10
        end

        final_score = "#{holland6_dimension.to_s}"

        {
          dimension: final_score,
          dimension_values: holland6_scores,
          adjust_by: adjust_by,
          version: '2.0'
        }
      end
    end
  end
end
