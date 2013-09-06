require File.expand_path('../base_analyzer.rb', __FILE__)

module TidepoolAnalyze
  module Analyzer
    class ImageRankAnalyzer < BaseAnalyzer
      attr_reader :images, :start_time, :end_time, :final_rank, :stage

      # Output Data Format:
      #   {
      #     "animal" => 10,
      #     "sunset" => 6,
      #      ...
      #    }
      def initialize(events, formula)
        @images = []
        @final_rank = []
        @events = events
      end
      
      # The image ranking comes in the range of [0..4]
      # This is the correct behaviour:
      # The lowest ranked image (4) will get a rank_multiplier 1
      def calculate_result
        process_events(@events)

        elements = {}
        i = 0
        @images.each do |image|
          element_list = image['elements'].split(',')
          rank_multiplier = 5 - @final_rank[i]
          element_list.each do |element_name|
            # "cf:" is a legacy prefix, if it exists remove it.
            element_name = element_name[3..-1] if element_name[0..2] == 'cf:'
            elements[element_name] ||= 0
            elements[element_name] += rank_multiplier
          end
          i += 1
        end

        elements
      end

      private

      def process_events(events)
        events.each do |entry|
          case entry['event']
          when 'level_started'
            @start_time = get_time(entry)
            @images = entry['data']
          when 'level_summary'
            @end_time = get_time(entry)
            @final_rank = entry['final_rank']
          end
        end
      end
    end
  end
end