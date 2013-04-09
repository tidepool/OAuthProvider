module TidepoolAnalyze
  module ScoreGenerator
    class Holland6Score
      def calculate_score(aggregate_results)
        # Holland6 comes from the Circles_Test modules
        holland6_scores = {
            realistic: 0,
            artistic: 0,
            social: 0,
            enterprising: 0,
            investigative: 0,
            conventional: 0
        }
        aggregate_results.each do | module_name, result |
          if result && result[:holland6]
            result[:holland6].each do |dimension, value|
              holland6_scores[dimension] += value[:average]
            end
          end
        end
        holland6_value = 0
        holland6_dimension = :realistic
        holland6_scores.each do |dimension, value|
          if value > holland6_value
            holland6_dimension = dimension
            holland6_value = value
          end
        end
        final_score = "#{holland6_dimension.to_s}"

        {
          holland6_dimension: final_score,
          holland6_scores: holland6_scores
        }
      end
    end
  end
end
