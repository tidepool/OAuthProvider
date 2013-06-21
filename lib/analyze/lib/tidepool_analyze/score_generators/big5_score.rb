module TidepoolAnalyze
  module ScoreGenerator
    class Big5Score
      def generate(mini_game_events, recipe)
        final_results = [] 
        recipe.each do |step|
          klass_name = "TidepoolAnalyze::Analyzer::#{step[:analyzer]}"
          intermediate_results = []
          mini_game_events[:big5].each do |stage, user_events|
            begin
              analyzer = klass_name.constantize.new(user_events)
              result = analyzer.calculate_result()
              intermediate_results << { stage: stage, results: result }
            rescue Exception => e
               raise e 
            end
          end

          klass_name = "TidepoolAnalyze::Formulator::#{step[:formulator]}"
          formula_loader.load(step[:formula_sheet])

          final_results <<  

        end

        calculate_score(final_results)
       end

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
        high_big5_value = -100000
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

        # Adjust the numbers so that the big5 scores are distributed >= (1 * 10) 
        # 1. Pick the min value
        # 2. Add abs(min_value) + 1 to all values 
        # 3. Multiply all values by 10 
        adjust_by = low_big5_value.abs + 1
        big5_scores.each do |dimension, value|
          big5_scores[dimension] = (value + adjust_by) * 10
        end

        # Pick either the lowest or the highest values depending on its absolute difference from average
        final_score = (high_big5_value - average_big5).abs > (low_big5_value - average_big5).abs ? "high_#{high_big5_dimension.to_s}" : "low_#{low_big5_dimension.to_s}"
        {
          dimension: final_score,
          score: big5_scores,
          low_dimension: low_big5_dimension,
          high_dimension: high_big5_dimension,
          adjust_by: adjust_by 
        }
      end
    end
  end
end