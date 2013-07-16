module TidepoolAnalyze
  module Analyzer
    class SurveyAnalyzer
      include TidepoolAnalyze::Utils::EventValidator

      attr_reader :start_time, :end_time

      def initialize(events, formula)
        @start_time = 0
        @end_time = 0
        @questions = []
        @events = events
      end

      # Output Format
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
      def calculate_result
        is_valid = process_events(@events)
        raise TidepoolAnalyze::UserEventValidatorError, "user_event invalid: #{invalid_event}, with missing key #{missing_key}" unless is_valid

        results = @questions.map do |question| 
          raise TidepoolAnalyze::UserEventValidatorError, "question not provided properly: #{question}" if question["question_id"].nil? || question["answer"].nil? || question["question_topic"].nil?
          {
            question_id: question["question_id"],
            answer: question["answer"],
            question_topic: question["question_topic"]
          }
        end
        results
      end

      private
      def process_events(events)
        is_valid = true
        events.each do |entry|
          unless user_event_valid?(entry)
            is_valid = false
            break
          end

          case entry['event_desc']
          when 'test_started'
            @start_time = entry['record_time']
          when 'test_completed'
            @end_time = entry['record_time']
            @questions = entry['questions']
          end
        end
        is_valid
      end
    end
  end
end