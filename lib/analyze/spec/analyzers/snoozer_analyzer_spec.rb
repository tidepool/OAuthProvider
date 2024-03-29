require 'spec_helper'

module TidepoolAnalyze
  module Analyzer
    describe SnoozerAnalyzer do
      before(:all) do
        # events_json = IO.read(File.expand_path('../../fixtures/aggregate_snoozer2.json', __FILE__))
        events_json = IO.read(File.expand_path('../../fixtures/realdata_snoozer.json', __FILE__))
        @user_events = JSON.parse(events_json)
      end

      it 'analyzes the snoozer events for simple' do 
        simple_events = @user_events[0]['events']
        snoozer_analyzer = SnoozerAnalyzer.new(simple_events, nil)
        result = snoozer_analyzer.calculate_result
        result.should_not be_nil
        result.should == {
          :test_type=>"simple",
          :test_duration=>12167,
          :average_time=>493,
          :slowest_time=>570,
          :fastest_time=>416,
          :score=>62,
          :total=>6,
          :total_correct=>2,
          :total_incorrect=>1,
          :total_missed=>3
        }

      end

      it 'analyzes the snoozer events for complex' do 
        complex_events = @user_events[3]['events']
        snoozer_analyzer = SnoozerAnalyzer.new(complex_events, nil)
        result = snoozer_analyzer.calculate_result
        result.should_not be_nil
        result.should == {
          :test_type=>"complex",
          :test_duration=>19245,
          :average_time=>415,
          :slowest_time=>465,
          :fastest_time=>361,
          :score=>279,
          :total=>12,
          :total_correct=>4,
          :total_incorrect=>0,
          :total_missed=>8
        }
      end

      it 'calculates correct hit scores' do 
        snoozer_analyzer = SnoozerAnalyzer.new(nil, nil)
        reaction_times = [-100, 0, 50, 100, 200, 300, 500, 700, 1000, 1200, 1500, 2000]
        scores = []
        expected_scores = []
        reaction_times.each do | reaction_time |
          scores << snoozer_analyzer.score_for_correct(reaction_time)
        end
      end

      it 'calculates incorrect hit scores' do 
        snoozer_analyzer = SnoozerAnalyzer.new(nil, nil)
        reaction_times = [-100, 0, 50, 100, 200, 300, 500, 700, 1000, 1200, 1500, 2000]
        scores = []
        expected_scores = []
        reaction_times.each do | reaction_time |
          scores << snoozer_analyzer.score_for_incorrect(reaction_time)
        end
      end
    end
  end
end
