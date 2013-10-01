require File.expand_path('../base_analyzer.rb', __FILE__)

module TidepoolAnalyze
  module Analyzer
    class FaceOffAnalyzer < BaseAnalyzer
      def initialize(events, formula)
        @events = events
        @emotions = {
          correct: [],
          incorrect: []
        }
      end

      def calculate_result
        process_events(@events)

        {
          primary_multiplier: @primary_multiplier,
          secondary_multiplier: @secondary_multiplier,
          difficulty_multiplier: @difficulty_multiplier,
          time_to_show: @time_to_show,
          time_elapsed: @end_time - @start_time,
          emotions: @emotions
        }
      end
    
      private
      def process_events(events)
        events.each do |entry|
          case entry['event']
          when 'level_started'
            @start_time = get_time(entry)
            @primary_multiplier = entry['primary_multiplier'] ? entry['primary_multiplier'].to_i : 1
            @secondary_multiplier = entry['secondary_multiplier'] ? entry['secondary_multiplier'].to_i : 1
            @time_to_show = entry['time_to_show'] ? entry['time_to_show'].to_i : 99999
            @difficulty_multiplier = entry['difficulty_multiplier'] ? entry['difficulty_multiplier'].to_i : 1
          when 'level_completed'
            @end_time = get_time(entry)
          when 'correct'
            @emotions[:correct] << {
              emotion: entry['value'],
              instant_replay: entry['instant_replay'] || 0,
              type: entry['type'] || "primary"
            }
          when 'incorrect'
            @emotions[:incorrect] << {
              emotion: entry['value'],
              instant_replay: entry['instant_replay'] || 0
            }
          end
        end
      end
    end
  end
end
