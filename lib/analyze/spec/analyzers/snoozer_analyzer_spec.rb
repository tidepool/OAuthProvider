require 'spec_helper'

module TidepoolAnalyze
  module Analyzer
    describe SnoozerAnalyzer do
      before(:all) do
        events_json = IO.read(File.expand_path('../../fixtures/aggregate_snoozer2.json', __FILE__))
        @user_events = JSON.parse(events_json)
      end

      it 'analyzes the snoozer events for simple' do 
        simple_events = @user_events[0]['events']
        snoozer_analyzer = SnoozerAnalyzer.new(simple_events, nil)
        result = snoozer_analyzer.calculate_result
        result.should_not be_nil
        result.should == {
          :test_type=>"simple",
          :test_duration=>17954,
          :average_time=>718,
          :slowest_time=>905,
          :fastest_time=>532,
          :score=>0,
          :total=>5,
          :total_correct=>2,
          :total_incorrect=>2,
          :total_missed=>1
        }
      end

      it 'analyzes the snoozer events for complex' do 
        complex_events = @user_events[1]['events']
        snoozer_analyzer = SnoozerAnalyzer.new(complex_events, nil)
        result = snoozer_analyzer.calculate_result
        result.should_not be_nil
        result.should == {
          :test_type => "complex",
          :test_duration => 17874,
          :average_time => 718,
          :slowest_time => 905,
          :fastest_time => 532,
          :score => 0,
          :total => 4,
          :total_correct => 2,
          :total_incorrect => 1,
          :total_missed => 1
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
