module TidepoolAnalyze
  module Analyzer
    class SurveyAnalyzer < BaseAnalyzer
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
        process_events(@events)

        results = @questions.map do |question| 
          {
            question_id: question["question_id"],
            answer: question["answer"],
            question_topic: question["topic"]
          }
        end
        results
      end

      private
      def process_events(events)
        events.each do |entry|
          case entry['event']
          when 'level_started'
            @start_time = get_time(entry)
          when 'level_completed'
            @end_time = get_time(entry)
          when 'level_summary'
            @questions = entry['data']
          end
        end
      end
    end
  end
end