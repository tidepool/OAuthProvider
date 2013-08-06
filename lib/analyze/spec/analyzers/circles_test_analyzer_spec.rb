require 'spec_helper'

module TidepoolAnalyze
  module Analyzer

    describe CirclesTestAnalyzer do
      before(:all) do
        events_json = IO.read(File.expand_path('../../fixtures/aggregate_circles_test.json', __FILE__))
        user_events = JSON.parse(events_json)[0]['events']
        formula_desc = {
          formula_sheet: 'big5_circles.csv',
          formula_key: 'name_pair'
        }

        @formula = TidepoolAnalyze::Utils.load_formula(formula_desc)
        @analyzer = CirclesTestAnalyzer.new(user_events, @formula)        
      end

      it 'has one fully overlapped circle with self circle' do
        overlapped = @analyzer.overlapped_circles(1.0)
        overlapped.length.should == 1
        overlapped[0][:trait1].should == 'Anxious'
      end

      it 'has one no-overlapped circle with self circle' do
        overlapped = @analyzer.overlapped_circles(0.0)
        overlapped.length.should == 1
        overlapped[0][:trait1].should == 'Self-Disciplined'
      end

      it 'has one overlapped circle between 50% - 100%' do
        overlapped = @analyzer.overlapped_circles(0.5, 1.0)
        overlapped.length.should == 1
        overlapped[0][:trait1].should == 'Cooperative'
      end

      it 'has one overlapped circle between 0% - 50%' do
        overlapped = @analyzer.overlapped_circles(0.0, 0.5)
        overlapped.length.should == 2
        traits = overlapped.find_all { |result| result[:trait1] == "Sociable" }
        traits[0][:trait1].should == "Sociable"  
      end

      it 'finds the closest circle to self circle' do
        closest_circle = @analyzer.closest_circle

        closest_circle[:trait1].should == "Anxious"
      end

      it 'should find the furthest circle to self circle' do
        furthest_circle = @analyzer.furthest_circle

        furthest_circle[:trait1].should == "Self-Disciplined"
      end

      it 'should create ranks for circles based on how far they are from self relative to each other' do
        expected_rank = {"Anxious" => 0, "Cooperative" => 1, "Sociable" => 2, "Curious" => 3, "Self-Disciplined" => 4}
        results = @analyzer.calculate_result
        results.each do |result|
          expected_rank[result[:trait1]].should == result[:distance_rank]
        end
      end

      it 'should create standard distances for circles based on the size of the self-circle' do
        results = @analyzer.calculate_result
        results.each do |result|
          result[:distance_standard].should == result[:distance] / result[:self_circle_radius]
        end
      end  

      # describe 'Edge and Error Cases' do 
      #   it 'raises an exception if the event is malformed' do
      #     events_json = IO.read(File.expand_path('../../fixtures/circles_test_malformed.json', __FILE__))
      #     user_events = JSON.parse(events_json)
      #     analyzer = CirclesTestAnalyzer.new(user_events, @formula)
      #     expect { analyzer.calculate_result }.to raise_error(TidepoolAnalyze::UserEventValidatorError)
      #   end
      # end
    end
  end
end
