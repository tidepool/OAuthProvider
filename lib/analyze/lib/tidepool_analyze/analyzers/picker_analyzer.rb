module TidepoolAnalyze
  module Analyzer
    class PickerAnalyzer 
      def initialize(events, formula)
        @events = events
        @symbols = []
        @words = []
      end

      def calculate_result
        process_events(@events)
        
        dimensions = {
            realistic: { word_count: 0, symbol_count: 0 },
            artistic: { word_count: 0, symbol_count: 0 },
            social: { word_count: 0, symbol_count: 0 },
            enterprising: { word_count: 0, symbol_count: 0 },
            investigative: { word_count: 0, symbol_count: 0 },
            conventional: { word_count: 0, symbol_count: 0 }
        }
        if @words && @words.class == Array
          @words.each do |word| 
            dimension = word['dimension']
            dimensions[dimension.to_sym][:word_count] += 1 if dimension && dimensions[dimension.to_sym] 
          end
        end
        if @symbols && @symbols.class == Array
          @symbols.each do |symbol|
            dimension = symbol['dimension']
            dimensions[dimension.to_sym][:symbol_count] += 1 if dimension && dimensions[dimension.to_sym]       
          end
        end
        dimensions
      end

      private
      def process_events(events)
        events.each do |entry|
          case entry['event']
          when 'level_started'
            @start_time = entry['time']
          when 'level_completed'
            @end_time = entry['time']
          when 'level_summary'
            @symbols = entry['symbol_list']
            @words = entry['word_list']
          end
        end
      end

    end
  end
end