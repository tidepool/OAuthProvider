require File.expand_path('../../utils/utils.rb', __FILE__)

module TidepoolAnalyze 
  module Formulator
    class DemandFormulator

      def initialize(input_data, formula)        
        @questions = TidepoolAnalyze::Utils::merge_across_stages(input_data)
        @formula = formula
      end

      # Input Data Format
      # [
      #   {
      #     question_id: "id123"
      #     answer: 5,
      #     question_topic: "foo"
      #   },
      #   { 
      #     question_id: "id12345"
      #     ...
      #   },
      #   ...
      # ]
      # Output Data Format
      # {
      #   question_topic1: {
      #     answer: ...
      #   },
      #   question_topic2: {
      #     ...
      #   },
      #   demand: {
      #     answer:
      #     zscore: ...
      #     tscore: ...
      #   }
      # }
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