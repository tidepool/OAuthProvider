module TidepoolAnalyze
  module Analyzer
    class ImageRankAnalyzer
      attr_reader :images, :start_time, :end_time, :final_rank, :stage

      # Output Data Format:
      # [
      #   {
      #     "animal" => 10,
      #     "sunset" => 6
      #      ...
      #    },
      #   {
      #     "animal" => 5,
      #     ...
      #   }
      # ]
      def initialize(events, formula)
        @images = []
        @final_rank = []
        process_events(events)
      end
      
      # The image ranking comes in the range of [0..4]
      # This is the correct behaviour:
      # The lowest ranked image (4) will get a rank_multiplier 1
      def calculate_result
        elements = {}
        return elements if @final_rank.nil? or @final_rank.length != 5
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
          case entry['event_desc']
          when 'test_started'
            @stage = entry['stage']
            @start_time = entry['record_time']
            @images = entry['image_sequence']
          when 'test_completed'
            @end_time = entry['record_time']
            @final_rank = entry['final_rank']
          when 'image_drag_start'
          when 'image_ranked'
          when 'image_rank_cleared'
          else
            puts "Unknown Event: #{entry}"
          end
        end
      end
    end
  end
end