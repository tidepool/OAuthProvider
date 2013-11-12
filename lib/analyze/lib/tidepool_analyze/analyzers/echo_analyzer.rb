require File.expand_path('../base_analyzer.rb', __FILE__)

module TidepoolAnalyze
  module Analyzer
    class EchoAnalyzer < BaseAnalyzer
      def initialize(events, formula)
        @events = events
      end

      def calculate_result
        process_events(@events)
        {
          score_multiplier: @score_multiplier,
          stage_type: @stage_type,
          highest: @highest
        }
      end
    
      private
      def process_events(events)
        events.each do |entry|
          case entry['event']
          when 'level_started'
            @start_time = get_time(entry)
            @score_multiplier = entry['score_multiplier'] ? entry['score_multiplier'].to_f : 1.0
            @stage_type = entry['stage_type'] || "forward"
          when 'level_completed'
            @end_time = get_time(entry)
          when 'level_summary'
            @highest = entry['highest'] ? entry['highest'].to_i : 1
          end
        end
      end
    end
  end
end