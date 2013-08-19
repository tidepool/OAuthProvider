require File.expand_path('../../utils/utils.rb', __FILE__)

module TidepoolAnalyze 
  module Formulator
    class SurveyFormulator

      def initialize(input_data, formula)        
        @questions = TidepoolAnalyze::Utils::merge_across_stages(input_data)
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
      #   question_topic1: answer1,
      #   question_topic2: answer2,
      #   ...
      # }
      def calculate_result
        answers = {}
        @questions.each do | question |
          question_topic = question[:question_topic]     
          if question_topic
            answers[question_topic.to_sym] = question[:answer]
          end
        end
        answers
      end
    end
  end
end