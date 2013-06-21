module TidepoolAnalyze 
  module Analyzer
    class CirclesTestAnalyzer
      attr_reader :start_time, :end_time, :circles, :radii, :start_coords, :self_circle

      def initialize(events)
        process_events events
      end

      def calculate_result
        @results = []
        return @results if @circles.nil? 
        
        self_circle_radius = @self_circle['size'] / 2.0
        self_circle_origin_x = @self_circle['left'] + self_circle_radius
        self_circle_origin_y = @self_circle['top'] + self_circle_radius
        @circles.each do |circle|
          result = {}
          result[:trait1] = circle['trait1']
          result[:trait2] = circle['trait2']
          result[:size] = circle['size']

          circle_radius = circle['width'] / 2.0

          result[:origin_x] = circle['left'] + circle_radius
          result[:origin_y] = circle['top'] + circle_radius
          result[:distance] = Math.sqrt((result[:origin_x] - self_circle_origin_x)**2 + (result[:origin_y] - self_circle_origin_y)**2)

          total_radius = circle_radius + self_circle_radius
          if result[:distance] >= total_radius
            # There is no overlap
            result[:overlap] = 0.0
          elsif result[:distance] <= self_circle_radius - circle_radius
            result[:overlap] = 1.0
          else
            result[:overlap_distance] = total_radius - result[:distance]
            result[:overlap] = (total_radius - result[:distance]) / (2 * circle_radius)
          end
          result[:total_radius] = total_radius
          result[:circle_radius] = circle_radius
          result[:self_circle_radius] = self_circle_radius
          
          if self_circle_radius && self_circle_radius != 0
            result[:distance_standard] = result[:distance] / self_circle_radius
          else
            # Log this, very unexpected!
          end
          @results << result
        end

        # Consistent ranges for size and distance rank -> [0..4]
        # This change required us to change the means in circles.csv to be mean - 1
        distance_rank = 0 # Changed this to start from 0.
        @results.sort {|p1, p2| p1[:distance] <=> p2[:distance] }.each do |result| 
          result[:distance_rank] = distance_rank
          distance_rank += 1
        end      
        @results
      end

      def overlapped_circles(percentage1, percentage2 = nil)
        @results ||= calculate_result()

        if percentage2.nil?
          @results.find_all { |result| result[:overlap] == percentage1 }     
        else
          small, large =  if percentage1 < percentage2
                            [percentage1, percentage2]
                          else
                            [percentage2, percentage1]
                          end
          @results.find_all { |result| result[:overlap] > small && result[:overlap] < large }
        end
      end

      def furthest_circle
        @results ||= calculate_result()

        return nil if @results.length == 0
        
        @results.inject(@results[0]) { |memo, result| memo[:distance] > result[:distance] ? memo : result }
      end

      def closest_circle
        @results ||= calculate_result()

        return nil if @results.length == 0
        
        @results.inject(@results[0]) { |memo, result| memo[:distance] < result[:distance] ? memo : result }
      end

      private
      def process_events(events)
        events.each do |entry|
          case entry['event_desc']
          when 'test_started'
            @start_time = entry['record_time']
          when 'move_circles_started'
          when 'test_completed'
            @end_time = entry['record_time']
            @circles = entry['circles']
            @self_circle = entry['self_coord']
          when 'circle_start_move'
          when 'circle_end_move'
          when 'circle_resized'
          else
            puts "Wrong Event: #{entry}"
          end
        end
      end
    end
  end
end
