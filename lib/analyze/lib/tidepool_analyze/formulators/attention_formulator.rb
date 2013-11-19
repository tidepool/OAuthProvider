module TidepoolAnalyze 
  module Formulator
    class AttentionFormulator

      def initialize(input_data, formula)
        @attention_results = input_data
      end

      # [ 
      #   {
      #     score_multiplier: @score_multiplier,
      #     stage_type: @stage_type,
      #     highest: @highest
      #   },
      #   {}
      # ]
      BASE_SCORE = 100
      def calculate_result
        total_score = 0
        stage_scores = []
        @attention_results.each do |result|
          score = result[:score_multiplier] * BASE_SCORE * result[:highest]
          stage_scores << {
            highest: result[:highest],
            score: score 
          }
          total_score += score
        end
        {
          attention_score: total_score.to_i,
          stage_scores: stage_scores
        }
      end
    end
  end
end