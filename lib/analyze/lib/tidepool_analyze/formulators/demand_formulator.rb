require File.expand_path('../../utils/utils.rb', __FILE__)

module TidepoolAnalyze 
  module Formulator
    class DemandFormulator

      def initialize(input_data, formula)        
        @questions = flatten_results_to_array(input_data)
        @formula = formula
      end

      def flatten_results_to_array(input_data)
        single_array = []
        input_data.each do | result |
          result.each do | raw_result |
            single_array << raw_result
          end
        end
        single_array
      end

      # Input Data Format
      def calculate_result
        # TODO: Currently we only expect to have one demand question
        # We will take the last demand question from the input_data
        values = @formula['demand_for_user_time']
        answer_zscore = 0.0
        @questions.each do | question |
          question_topic = question[:question_topic]
          if question_topic == 'demand'
            answer = question[:answer]
            answer_zscore = TidepoolAnalyze::Utils::zscore(answer, values.mean, values.std) 
          end
        end
        values = @formula['demand_and_reaction_time_correction']
        corrected_answer = answer_zscore * values.correction_coefficient
        corrected_answer_tscore = TidepoolAnalyze::Utils::tscore(answer_zscore)
        {
          demand: corrected_answer_tscore
        }
      end
    end
  end
end