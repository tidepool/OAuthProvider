require 'spec_helper'

module TidepoolAnalyze
  module Aggregator

    describe 'Circles Test Aggregator' do
      before(:all) do
        stages_json = IO.read(File.expand_path('../../fixtures/circles_definition.json', __FILE__))
        # TODO: Change the stages_json parse to symbolize_names
        @stages = JSON.parse stages_json
        circles_raw_results_json =  IO.read(File.expand_path('../../fixtures/circles_raw_results.json', __FILE__))
        @circles_raw_results = JSON.parse circles_raw_results_json, :symbolize_names => true
        @current_analysis_version = '1.0'

        circles = YAML::load(IO.read(File.expand_path('../../fixtures/circles.yaml', __FILE__)))
        new_circles = {}
        circles.each { |circle, value| new_circles[circle] = ::OpenStruct.new(value) }
        
        @aggregator = CirclesTestAggregator.new(@circles_raw_results, @stages)
        @aggregator.circles = new_circles
      end

      it 'should break into 3 different assessment types' do
        raw_results_by_type = @aggregator.break_into_assessment_types
        raw_results_by_type.length.should == 3
        raw_results_by_type[:Big5].length.should == 10
        raw_results_by_type[:Emo8].length.should == 8
        raw_results_by_type[:Holland6].length.should == 6
      end

      it 'should calculate the z-score correctly' do
        score = @aggregator.zscore(2.3, 3.0, 1.2)
        score.should == (2.3 - 3.0)/1.2
      end

      it 'should return a zscore of 0, if sd = 0.0' do
        score = @aggregator.zscore(2.3, 3.0, 0.0)
        score.should == 0.0
      end

      it 'should return the correct zscores for Sociable/Adventurous' do
        circle = @aggregator.circles['Sociable/Adventurous']
        size_zscore, distance_zscore, overlap_zscore = @aggregator.calculate_zscores(2, 3, 0.53, circle)

        # From the spreadsheet:
        size_mean = 3.5
        size_sd = 1.3
        size_zscore.should == (2 - size_mean) / size_sd

        distance_mean = 3.2
        distance_sd = 1.2
        distance_zscore.should == (3 - distance_mean) / distance_sd

        overlap_mean = 31.7/100
        overlap_sd = 16.7/100
        overlap_zscore.should == (0.53 - overlap_mean) / overlap_sd
      end

      it 'should calculate Extraversion values for Big5' do
        raw_results = [{
                          :trait1 => 'Sociable',
                          :trait2 => 'Adventurous',
                          :size => 2,
                          :distance_rank => 3,
                          :overlap => 0.53
                       },
                       {
                          :trait1 => 'Self-Reflective',
                          :trait2 => 'Reserved',
                          :size => 3,
                          :distance_rank => 1,
                          :overlap => 1
                       }
                      ]
        weighted_result = @aggregator.result_by_assessment_type(raw_results)
        weighted_result[:Extraversion].should_not be_nil
        weighted_result.length.should == 1
        weighted_result[:Extraversion][:count].should == 2
        weighted_result[:Extraversion][:weighted_total].should be_within(0.0005).of(-2.1749)
        weighted_result[:Extraversion][:average].should be_within(0.0005).of(-1.0874)
      end

      it 'should calculate all 3 assessment types' do
        result = @aggregator.calculate_result
        result.length.should == 3
        result[:Big5].should_not be_nil
        result[:Holland6].should_not be_nil
        #result[:Emo8].should_not be_nil
      end

      it 'should have all 5 dimensions for Big5 and calculated from 2 sets of name-pairs' do
        result = @aggregator.calculate_result
        result[:Big5][:Openness].should_not be_nil
        result[:Big5][:Openness][:count].should == 2
        result[:Big5][:Agreeableness].should_not be_nil
        result[:Big5][:Agreeableness][:count] == 2
        result[:Big5][:Conscientiousness].should_not be_nil
        result[:Big5][:Conscientiousness][:count] == 2
        result[:Big5][:Extraversion].should_not be_nil
        result[:Big5][:Extraversion][:count] == 2
        result[:Big5][:Neuroticism].should_not be_nil
        result[:Big5][:Neuroticism][:count] == 2
      end
    end
  end
end