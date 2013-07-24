require 'spec_helper'

module TidepoolAnalyze
  module Analyzer
    describe SnoozerAnalyzer do
      before(:all) do
        events_json = IO.read(File.expand_path('../../fixtures/snoozer.json', __FILE__))
        @user_events = JSON.parse(events_json)
      end

      it 'analyzes the snoozer events' do 
        snoozer_analyzer = SnoozerAnalyzer.new(@user_events, nil)
        result = snoozer_analyzer.calculate_result

        result.should_not be_nil
        result[:average_time_to_click].should == 400
        result[:max_time_to_click_above_threshold].should == 500
        result[:min_time_to_click_above_threshold].should == 300
      end
    end
  end
end
