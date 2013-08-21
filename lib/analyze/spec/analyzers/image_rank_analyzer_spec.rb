require 'spec_helper'

module TidepoolAnalyze
  module Analyzer
    describe ImageRankAnalyzer do 
      before(:all) do
        events_json = IO.read(File.expand_path('../../fixtures/aggregate_image_rank.json', __FILE__))
        @user_events = JSON.parse(events_json)['events']

        @expected_elements = {
          "color"=>15,
          "human"=>14,
          "male"=>13,
          "man_made"=>13,
          "movement"=>12,
          "nature"=>7,
          "pair"=>13,
          "reflection"=>13,
          "texture"=>10,
          "whole"=>11,
          "human_eyes"=>5,
          "negative_space"=>3,
          "happy"=>2,
          "shading"=>6,
          "vista"=>2
        }
      end

      it 'has a final rank' do
        analyzer = ImageRankAnalyzer.new(@user_events, nil)
        analyzer.calculate_result
        analyzer.final_rank.length.should equal(5)
        ranks_exist = {}
        analyzer.final_rank.each { |rank| ranks_exist[rank.to_s] = 1 }
        (0..4).each { |number| ranks_exist[number.to_s].should equal(1) }
      end

      it 'has the correct number of elements' do
        analyzer = ImageRankAnalyzer.new(@user_events, nil)
        result = analyzer.calculate_result
        result.length.should == @expected_elements.length
      end

      it 'calculates the correct rank for element male' do
        analyzer = ImageRankAnalyzer.new(@user_events, nil)
        result = analyzer.calculate_result
        result.should == @expected_elements
      end

      # describe 'Edge and Error Cases' do 
      #   it 'raises an exception if the event is malformed' do
      #     events_json = IO.read(File.expand_path('../../fixtures/image_rank_malformed.json', __FILE__))
      #     user_events = JSON.parse(events_json)
      #     image_rank_analyzer = ImageRankAnalyzer.new(user_events, nil)
      #     expect { image_rank_analyzer.calculate_result }.to raise_error(TidepoolAnalyze::UserEventValidatorError)
      #   end
      # end
    end
  end
end
