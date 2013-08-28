module TidepoolAnalyze
  module Analyzer
    class SnoozerAnalyzer
      def initialize(events, formula)
        @events = events
        @test_type = 'simple'
        @start_time = 0
        @end_time = 0
        @items_shown = {}
        @high_score = 1000
        @low_score = 200
        @ceiling = 1500
        @floor = 10
        @multiplier = 1
        @dist_coef = 2.4
        @offset = 0.1
      end

      def calculate_result
        process_events(@events)
        @multiplier = 1.5 if @test_type == 'complex'
        total_shown = @items_shown.length
        missed = 0
        correct = 0
        incorrect = 0
        total_time = 0
        average_time = 0
        slowest_time = 0
        fastest_time = 100000
        score = 0

        @items_shown.each do |item_id, entry|
          case entry[:selection]
          when :none
            missed += 1 if entry[:type] != :decoy
          when :correct
            correct += 1
            reaction_time = entry[:selected_at] - entry[:shown_at]
            score += score_for_correct(reaction_time)
            slowest_time = reaction_time if reaction_time > slowest_time
            fastest_time = reaction_time if reaction_time < fastest_time
            total_time = total_time + reaction_time               
          when :incorrect
            incorrect += 1
            reaction_time = entry[:selected_at] - entry[:shown_at]
            score += score_for_incorrect(reaction_time)
          end
        end

        average_time = total_time / correct if correct > 0
        score = 0 if score < 0
        {
          test_type: @test_type,
          test_duration: @end_time - @start_time,
          average_time: average_time,
          slowest_time: slowest_time,
          fastest_time: fastest_time,
          score: score.to_i,
          total: total_shown,
          total_correct: correct,
          total_incorrect: incorrect,
          total_missed: missed
        }
      end

      def score_for_correct(reaction_time)
        reaction_time = @ceiling if reaction_time > @ceiling || reaction_time < 0
        score = @high_score / Math.exp((1 - (@ceiling - reaction_time)/@ceiling.to_f) * @dist_coef + @offset) 
        score = score * @multiplier
        score.to_i
      end

      def score_for_incorrect(reaction_time)
        reaction_time = @ceiling if reaction_time > @ceiling || reaction_time < 0
        score = -1 * ((@ceiling - reaction_time)/@ceiling.to_f*(@high_score - @low_score) + @low_score) 
        score = score * @multiplier
        score.to_i
      end

      private
      def process_events(events)
        events.each do |entry|
          case entry['event']
          when 'level_started'
            @test_type = entry['sequence_type']
            @start_time = entry['time']
          when 'level_completed'
            @end_time = entry['time']
          when 'shown'
            # We are using a Hash instead of an Array
            # We will look for each sequence in the event processing later on
            item_id = entry['item_id']
            if item_id
              @items_shown[item_id] = {
                :shown_at => entry['time'],
                :selection => :none,
                :type => entry['type'] 
              }
            end
          when 'correct'
            item_id = entry['item_id']
            if item_id && @items_shown[item_id]
              @items_shown[item_id][:selection] = :correct
              @items_shown[item_id][:selected_at] = entry['time']
            end
          when 'incorrect'
            item_id = entry['item_id']
            if item_id
              if @items_shown[item_id]
                @items_shown[item_id][:selection] = :incorrect
                @items_shown[item_id][:selected_at] = entry['time']
              else  
                # This is for tapping on items that are not ringing, 
                # but simply shown at the beginning of the game.
                @items_shown[item_id] = {
                  :shown_at => @start_time,
                  :selection => :incorrect,
                  :selected_at => entry['time']
                }
              end
            end
          end
        end
      end
    end
  end
end