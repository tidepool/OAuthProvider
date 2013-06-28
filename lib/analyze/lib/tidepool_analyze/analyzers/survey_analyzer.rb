module TidepoolAnalyze
  module Analyzer
    class SurveyAnalyzer
      attr_reader :start_time, :end_time

      def initialize(events, formula)
        @start_time = 0
        @end_time = 0
        @questions = []
        process_events(events)
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
        @questions
      end

      private
      def process_events(events)
        events.each do |entry|
          case entry['event_desc']
          when 'test_started'
            @start_time = entry['record_time']
          when 'test_completed'
            @end_time = entry['record_time']
          when 'changed'
            @questions << {
              question_id: entry['question_id'],
              answer: entry['answer'],
              question_topic: entry['question_topic']
            }
          else
            puts "Unknown Event: #{entry}"
          end
        end
      end
    end
  end
end