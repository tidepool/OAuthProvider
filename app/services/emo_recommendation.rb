# class EmoRecommendation
#   def initialize(result) 
#     @emo_name = result.calculated_emotion

#     factor1 = result.calculations["final_results"][0]["factors"]["factor1"]
#     factor1_zscore = factor1["average_zscore"]
#     @percentile = find_percentile(factor1_zscore)
#   end

#   def recommendation
#     emo_desc = EmotionDescription.where(name: @emo_name).first
#     emo_factor_recommendation = EmotionFactorRecommendation.where(name: 'factor1').first
#     if emo_factor_recommendation && emo_factor_recommendation.recommendations_per_percentile.length >= @percentile
#       factor_recommendation = emo_factor_recommendation.recommendations_per_percentile[@percentile]
#     else
#       factor_recommendation = nil
#     end

#     {
#       emotion: emo_desc.name,
#       friendly_name: emo_desc.friendly_name,
#       title: emo_desc.title,
#       description: emo_desc.description,
#       factor_recommendation: factor_recommendation,
#       all_factor_recommendations: emo_factor_recommendation.recommendations_per_percentile
#     }
#   end

#   def find_percentile(zscore)
#     percentiles = [-0.8416, -0.2533, 0.2533, 0.8416, 10]

#     percentile = 0 
#     percentiles.each_index do | index |
#       if zscore < percentiles[index]
#         percentile = index
#         break;
#       end
#     end
#     percentile
#   end
# end