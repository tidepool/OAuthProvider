module TidepoolAnalyze
  module Analyzer
    class ReactionTimeAnalyzer
      include TidepoolAnalyze::Utils::EventValidator

      attr_reader :start_time, :end_time, :test_type, :click_targets, :color_sequence 
      attr_accessor :time_threshold

      #threshold is used to figure out clicks within and total and then subtract out

      def initialize(events, formula)
        @events = events
        @click_targets = {}
        @start_time = 0
        @end_time = 0
        @test_type = 'simple'
        @correct_color = 'red'
        @time_threshold = 200
        @color_sequence = []
      end

      # Raw results are returned for each stage:
      # {
      #   test_type: 'simple' || 'complex',
      #   test_duration: 12220,
      #   correct_clicks_above_threshold: 3,
      #   clicks_above_threshold: 4,
      #   average_time_to_click: 257,
      #   min_time_to_click_above_threshold: 210,
      #   max_time_to_click_above_threshold: 340 
      # }

      # Time is coming from the browsers as EpochTime in number of miliseconds since Jan 1, 1970.
      # Ruby (and Unix) Epoch time is measured in seconds since Jan 1, 1970.
      def calculate_result
        is_valid = process_events(@events)
        raise RuntimeError, "user_event invalid: #{invalid_event}" unless is_valid

        total_clicks = 0
        correct_clicks = 0
        average_time = 0
        total_time = 0
        max_time_to_click_above_threshold = 0
        min_time_to_click_above_threshold = 100000
        return {} unless @click_targets.has_key?(@correct_color)

        @click_targets[@correct_color].each do |key, value|
          time_to_click = value[:clicked_at] - value[:shown_at]
          if value[:clicked] and (time_to_click > @time_threshold) 
            total_clicks += 1
            if value[:expected]
              correct_clicks += 1
              total_time += time_to_click
              max_time_to_click_above_threshold = time_to_click if time_to_click > max_time_to_click_above_threshold
              min_time_to_click_above_threshold = time_to_click if time_to_click < min_time_to_click_above_threshold
            end
          end
        end
        average_time = total_time / correct_clicks if correct_clicks > 0

        return {
          test_type: @test_type,
          test_duration: @end_time - @start_time,
          correct_clicks_above_threshold: correct_clicks,
          clicks_above_threshold: total_clicks,
          average_time_to_click: average_time,
          max_time_to_click_above_threshold: max_time_to_click_above_threshold,
          min_time_to_click_above_threshold: min_time_to_click_above_threshold
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
          when 'test_started'
            @test_type = entry['sequence_type']
            @start_time = entry['record_time']
            if entry['color_sequence'] 
              @color_sequence = entry['color_sequence'].map do |item|
                color, time_interval = item.split(':')
                {color: color, time_interval: time_interval}
              end 
            end
          when 'test_completed'
            @end_time = entry['record_time']
          when 'circle_shown'
            color = entry['circle_color']

            # We are using a Hash instead of an Array
            # We will look for each sequence in the event processing later on
            sequence_no = entry['sequence_no']
            if color && sequence_no
              create_click_target_entry(color, sequence_no, {
                :shown_at => entry['record_time'],
                :clicked => false,
                :clicked_at => 0, 
                :expected => true 
                })
            end
          when 'correct_circle_clicked'
            color = entry['circle_color']
            sequence_no = entry['sequence_no']
            if color && sequence_no
              create_click_target_entry(color, sequence_no, {
                  :clicked => true,
                  :clicked_at => entry['record_time'],
                  :expected => true
                })
            end
          when 'wrong_circle_clicked'
            color = entry['circle_color']
            sequence_no = entry['sequence_no']
            if color && sequence_no
              create_click_target_entry(color, sequence_no, {
                :clicked => true,
                :clicked_at => entry['record_time'],
                :expected => false              
                })
            end
          end
        end
        is_valid
      end

      def create_click_target_entry(color, sequence_no, values)
        @click_targets[color] ||= {}
        @click_targets[color][sequence_no] ||= {}
        @click_targets[color][sequence_no] = @click_targets[color][sequence_no].merge(values)
      end
    end
  end
end

