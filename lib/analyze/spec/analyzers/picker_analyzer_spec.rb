require 'spec_helper'

module TidepoolAnalyze
  module Analyzer
    describe PickerAnalyzer do
      before(:all) do
        events_json = IO.read(File.expand_path('../../fixtures/aggregate_interest_picker.json', __FILE__))
        @user_events = JSON.parse(events_json)['events']
      end

      it 'analyzes the snoozer events for simple' do 
        picker_analyzer = PickerAnalyzer.new(@user_events, nil)
        result = picker_analyzer.calculate_result
        result.should_not be_nil
        result.should == {
          :realistic=>{:word_count=>3, :symbol_count=>1},
          :artistic=>{:word_count=>0, :symbol_count=>0},
          :social=>{:word_count=>2, :symbol_count=>0},
          :enterprising=>{:word_count=>0, :symbol_count=>2},
          :investigative=>{:word_count=>1, :symbol_count=>0},
          :conventional=>{:word_count=>1, :symbol_count=>0}
        }
      end

    end
  end
end