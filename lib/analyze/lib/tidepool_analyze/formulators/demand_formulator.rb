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
        answers = {}
        @questions.each do | question |
          question_topic = question[:question_topic]     
          answers[question_topic.to_sym] = {}     
          answers[question_topic.to_sym][:answer] = question[:answer]
          if question_topic == 'demand'
            # For now we are only calculating zscore and tscore for demand
            # I am just recording the answers to the other question_topics 
            answers[question_topic.to_sym][:zscore] = TidepoolAnalyze::Utils::zscore(answers[question_topic.to_sym][:answer], values.mean, values.std) 
            
            values = @formula['demand_and_reaction_time_correction']
            corrected_answer = answers[question_topic.to_sym][:zscore] * values.correction_coefficient
            answers[question_topic.to_sym][:tscore] = TidepoolAnalyze::Utils::tscore(corrected_answer)
          end
        end
        answers
      end
    end
  end
end