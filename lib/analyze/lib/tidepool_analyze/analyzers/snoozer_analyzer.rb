module TidepoolAnalyze
  module Analyzer
    class SnoozerAnalyzer
      include TidepoolAnalyze::Utils::EventValidator

      def initialize(events, formula)
        @events = events
        @average_time = 0
        @fastest_time = 0
        @slowest_time = 0
      end

      def calculate_result
        is_valid = process_events(@events)
        raise TidepoolAnalyze::UserEventValidatorError, "user_event invalid: #{invalid_event}, with missing key #{missing_key}" unless is_valid

        return {
          average_time_to_click: @average_time,
          max_time_to_click_above_threshold: @slowest_time,
          min_time_to_click_above_threshold: @fastest_time
        }
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
          when 'level_summary'
            @fastest_time = entry['fastest_time']
            @slowest_time = entry['slowest_time']
            @average_time = entry['average_time']
          end
        end
      end
    end
  end
end