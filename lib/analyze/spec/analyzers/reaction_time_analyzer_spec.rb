require 'spec_helper'

module TidepoolAnalyze
  module Analyzer
    describe ReactionTimeAnalyzer do 
      before(:all) do
        events_json = IO.read(File.expand_path('../../fixtures/test_event_log.json', __FILE__))
        @user_events = JSON.parse(events_json)
      end

      it 'should record the test end time and greater than start_time' do
        simple_events = @user_events.find_all { |event| event['module'] == 'reaction_time' && event['sequence_type'] == 'simple'}
        reaction_time_analyzer = ReactionTimeAnalyzer.new(simple_events, nil)
        reaction_time_analyzer.calculate_result
        # Note: JS time is reported in ms, Ruby is in sec for Epoch time
        start_time = Time.at(reaction_time_analyzer.start_time/1000)    
        end_time = Time.at(reaction_time_analyzer.end_time/1000)
        (end_time - start_time).should be > 0
      end

      it 'calculates the result for the simple reaction_time' do
        simple_events = @user_events.find_all { |event| event['module'] == 'reaction_time' && event['sequence_type'] == 'simple'}
        reaction_time_analyzer = ReactionTimeAnalyzer.new(simple_events, nil)
        result = reaction_time_analyzer.calculate_result
        result.should_not be_nil
        result[:test_type].should == 'simple'
        result[:test_duration].should > 0
        result[:correct_clicks_above_threshold].should == 3 # This depends on the input data
        result[:clicks_above_threshold].should >= result[:correct_clicks_above_threshold]
        result[:average_time_to_click].should_not be_nil
        result[:max_time_to_click_above_threshold].should_not == 0
        result[:min_time_to_click_above_threshold].should_not == 100000
        result[:max_time_to_click_above_threshold].should >= result[:min_time_to_click_above_threshold]
      end

      it 'calculates the result for the complex reaction_time' do
        complex_events = @user_events.find_all { |event| event['module'] == 'reaction_time' && event['sequence_type'] == 'complex'}
        reaction_time_analyzer = ReactionTimeAnalyzer.new(complex_events, nil)
        result = reaction_time_analyzer.calculate_result
        result.should_not be_nil
        result[:test_type].should == 'complex'
        result[:test_duration].should > 0
        result[:correct_clicks_above_threshold].should == 1 # This depends on the input data
        result[:clicks_above_threshold].should >= result[:correct_clicks_above_threshold]
        result[:average_time_to_click].should_not be_nil
        result[:max_time_to_click_above_threshold].should_not == 0
        result[:min_time_to_click_above_threshold].should_not == 100000
        result[:max_time_to_click_above_threshold].should >= result[:min_time_to_click_above_threshold]
      end

      it 'removes clicks below the threshold' do 
        simple_events = @user_events.find_all { |event| event['module'] == 'reaction_time' && event['sequence_type'] == 'simple'}
        reaction_time_analyzer = ReactionTimeAnalyzer.new(simple_events, nil)
        reaction_time_analyzer.time_threshold = 600
        result = reaction_time_analyzer.calculate_result
        result.should_not be_nil
        result[:correct_clicks_above_threshold].should == 2 # This depends on the input data
        result[:min_time_to_click_above_threshold].should > 600 
      end

      it 'shows all the colors in the color_sequence' do
        simple_events = @user_events.find_all { |event| event['module'] == 'reaction_time' && event['sequence_type'] == 'simple'}
        reaction_time_analyzer = ReactionTimeAnalyzer.new(simple_events, nil)

        color_sequence = reaction_time_analyzer.color_sequence
        click_targets = reaction_time_analyzer.click_targets
        color_instances = {}
        color_sequence.each do | entry |
          color_instances[entry[:color]] = 0 if color_instances[entry[:color]].nil?
          color_instances[entry[:color]] += 1 
        end
        click_targets.each do |key, value|
          value.length.should == color_instances[key]
        end
      end

      describe 'Edge and Error Cases' do 
        it 'raises an exception if the event is malformed' do
          events_json = IO.read(File.expand_path('../../fixtures/reaction_time_malformed.json', __FILE__))
          user_events = JSON.parse(events_json)
          reaction_time_analyzer = ReactionTimeAnalyzer.new(user_events, nil)
          expect { reaction_time_analyzer.calculate_result }.to raise_error(RuntimeError)
        end
      end
    end
  end
end