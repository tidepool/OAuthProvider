module TidepoolAnalyze 
  module Analyzer
    class CirclesTestAnalyzer
      include TidepoolAnalyze::Utils::EventValidator

      attr_reader :start_time, :end_time, :circles, :radii, :start_coords, :self_circle

      # Output Format:
      # [
      #   [
      #     {:trait1=>"Self-Disciplined",
      #      :trait2=>"Persistent",
      #      :name_pair=>"Self-Disciplined/Persistent",
      #      :size=>2,
      #      :origin_x=>441.0,
      #      :origin_y=>215.0,
      #      :distance=>403.05334634512093,
      #      :overlap=>0.0,
      #      :total_radius=>259.0,
      #      :circle_radius=>66.0,
      #      :self_circle_radius=>193.0,
      #      :distance_standard=>2.088359307487673,
      #      :distance_rank=>4},
      #     {...},
      #   ],
      #   [
      #     {:trait1=>"Cooperative",
      #      :trait2=>"Friendly",
      #      :name_pair=>"Cooperative/Friendly",
      #      :size=>2,
      #      :origin_x=>953.0,
      #      :origin_y=>192.0,
      #      :distance=>187.608635195718,
      #      :overlap_distance=>71.391364804282,
      #      :overlap=>0.5408436727597121,
      #      :total_radius=>259.0,
      #      :circle_radius=>66.0,
      #      :self_circle_radius=>193.0,
      #      :distance_standard=>0.9720654673353264,
      #      :distance_rank=>2},
      #     {...}
      #   ]
      # ]
      def initialize(events, formula)
        @formula = formula
        @events = events
      end

      def calculate_result
        process_events(@events)
        
        self_circle_radius = @self_circle['size'] / 2.0
        self_circle_origin_x = @self_circle['left'] + self_circle_radius
        self_circle_origin_y = @self_circle['top'] + self_circle_radius

        raise TidepoolAnalyze::UserEventValidatorError, "self circle radius can not be zero" if self_circle_radius.nil? || self_circle_radius == 0

        @results = []
        @circles.each do |circle|
          if circle['trait2'].nil? || circle['trait2'].empty?
            name_pair = circle['trait1']
          else
            name_pair = "#{circle['trait1']}/#{circle['trait2']}"
          end

          # Check if this name_pair needs to be processed based on the formula given?
          if @formula.has_key?(name_pair)
            result = {}

            result[:trait1] = circle['trait1']
            result[:trait2] = circle['trait2']
            result[:name_pair] = name_pair

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
        end

        if @results.length > 0
          # Consistent ranges for size and distance rank -> [0..4]
          # This change required us to change the means in circles.csv to be mean - 1
          distance_rank = 0 # Changed this to start from 0.
          @results.sort {|p1, p2| p1[:distance] <=> p2[:distance] }.each do |result| 
            result[:distance_rank] = distance_rank
            distance_rank += 1
          end   
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
          case entry['event']
          when 'level_started'
            @start_time = entry['time']
          when 'level_summary'
            @end_time = entry['time']
            @circles = entry['data']
            @self_circle = entry['self_coord']
          end
        end
      end
    end
  end
end
