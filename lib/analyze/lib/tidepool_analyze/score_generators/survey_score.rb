module TidepoolAnalyze
  module ScoreGenerator
    class SurveyScore 
      def calculate_score(input_data)
        raise CalculationError, "No input data" if input_data.nil? || input_data.empty?
        
        # Just pass it through

        input_data[0].merge({ version: '2.0' })
      end
    end
  end
end