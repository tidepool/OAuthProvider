module TidepoolAnalyze
  module ScoreGenerator
    class EmoScore
      def calculate_score(input_data)
        raise CalculationError, "No input data" if input_data.nil? || input_data.empty?

        emo_scores = {
          factor1: 0,
          factor2: 0,
          factor3: 0,
          factor4: 0,
          factor5: 0
        }
        weakest_emotion = nil
        strongest_emotion = nil
        calculated_emotion = nil
        reported_emotion = nil

        input_data.each do | result |
          if result[:emotion]
            # Self reported emotion
            raise CalculationError, "Answer is missing" if result[:emotion][:answer].nil?

            reported_emotion = result[:emotion][:answer]
          else
            # Calculate emotion from circles game
            raise CalculationError, "Factors are missing" if result[:factors].nil? || result[:factors].empty?
            raise CalculationError, "Furthest emotion missing" if result[:weakest_emotion].nil?
            raise CalculationError, "Closest emotion missing" if result[:strongest_emotion].nil?

            result[:factors].each do | factor_name, value |
              emo_scores[factor_name] = TidepoolAnalyze::Utils::tscore(value[:average_zscore])
            end
            flagged_result1 = result[:flagged_result1]
            weakest_emotion = result[:weakest_emotion]
            strongest_emotion = result[:strongest_emotion]

            calculated_emotion = strongest_emotion[:emotion]
            if flagged_result1 && flagged_result1 == "true"
              calculated_emotion = "flagged_result1"
            end

          end
        end

        {
          factors: emo_scores,
          weakest_emotion: weakest_emotion,
          strongest_emotion: strongest_emotion,
          reported_emotion: reported_emotion,
          calculated_emotion: calculated_emotion,
          version: '2.0'
        }
      end
    end

  end
end
