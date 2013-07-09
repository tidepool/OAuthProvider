module TidepoolAnalyze
  module ScoreGenerator
    class EmoScore
      def calculate_score(input_data)
        if input_data && input_data.class.to_s == 'Array' && !input_data.empty?
          input_data = input_data[0]
        end
        raise RuntimeError, "Factors are missing" if input_data[:factors].nil? || input_data[:factors].empty?
        raise RuntimeError, "Furthest emotion missing" if input_data[:weakest_emotion].nil?
        raise RuntimeError, "Closest emotion missing" if input_data[:strongest_emotion].nil?

        emo_scores = {
          factor1: 0,
          factor2: 0,
          factor3: 0,
          factor4: 0,
          factor5: 0
        }

        input_data[:factors].each do | factor_name, value |
          emo_scores[factor_name] = TidepoolAnalyze::Utils::tscore(value[:average_zscore])
        end

        {
          factors: emo_scores,
          flagged_result1: input_data[:flagged_result1],
          weakest_emotion: input_data[:weakest_emotion],
          strongest_emotion: input_data[:strongest_emotion]
        }
      end
    end

  end
end
