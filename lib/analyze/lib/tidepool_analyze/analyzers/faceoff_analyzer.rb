require File.expand_path('../base_analyzer.rb', __FILE__)

module TidepoolAnalyze
  module Analyzer
    class FaceOffAnalyzer < BaseAnalyzer
      def initialize(events, formula)

      end
    end

    private
    def process_events(events)
      events.each do |entry|
        case entry['event']
        when 'level_started'
          @start_time = get_time(entry)
        when 'level_completed'
          @end_time = get_time(entry)
        when 'correct'
          item_id = entry['item_id']
          if item_id && @items_shown[item_id]
            @items_shown[item_id][:selection] = :correct
            @items_shown[item_id][:selected_at] = get_time(entry)
          end
        when 'incorrect'
          item_id = entry['item_id']

        end
      end
    end
  end
end
