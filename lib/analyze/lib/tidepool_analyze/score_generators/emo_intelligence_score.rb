module TidepoolAnalyze
  module ScoreGenerator
    class EmoIntelligenceScore
      def calculate_score(input_data)
        output = {}
        input_data.each do |result|
          if result.has_key?(:corrects) 
            output.merge!(result)
          end
        end
        output.merge!({ version: '2.0' })
        output
      end
    end
  end
end