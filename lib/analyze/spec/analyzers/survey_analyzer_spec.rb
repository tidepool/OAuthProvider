require 'spec_helper'

module TidepoolAnalyze
  module Analyzer
    describe SurveyAnalyzer do
      before(:all) do
        events_json = IO.read(File.expand_path('../../fixtures/survey.json', __FILE__))
        @user_events = JSON.parse(events_json)
      end

      it 'records the start and end times' do
        survey_analyzer = SurveyAnalyzer.new(@user_events, nil)
        survey_analyzer.calculate_result

        survey_analyzer.start_time.should_not == 0
        survey_analyzer.end_time.should_not == 0
      end

      it 'analyzes the user events and returns questions' do
        survey_analyzer = SurveyAnalyzer.new(@user_events, nil)
        questions = survey_analyzer.calculate_result
        questions.length.should == 3
        question = questions[0]
        question[:question_id].should == 'demand_1234'
        question[:question_topic].should == 'demand'
        question[:answer].should == 5
      end

      describe 'Edge and Error Cases' do 
        it 'raises an exception if the event is malformed' do
          events_json = IO.read(File.expand_path('../../fixtures/survey_malformed.json', __FILE__))
          user_events = JSON.parse(events_json)
          survey_analyzer = SurveyAnalyzer.new(user_events, nil)
          expect { survey_analyzer.calculate_result }.to raise_error(TidepoolAnalyze::UserEventValidatorError)
        end
      end
    end
  end
end