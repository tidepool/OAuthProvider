require 'spec_helper'

module TidepoolAnalyze
  module Formulator

    describe ReactionTimeFormulator do 
      before(:all) do
        @input_data = [
          {
            test_type: 'simple',
            test_duration: 12220,
            correct_clicks_above_threshold: 3,
            clicks_above_threshold: 4,
            average_time_to_click: 257,
            min_time_to_click_above_threshold: 210,
            max_time_to_click_above_threshold: 340 
          },
          {
            test_type: 'complex',
            test_duration: 10220,
            correct_clicks_above_threshold: 2,
            clicks_above_threshold: 4,
            average_time_to_click: 300,
            min_time_to_click_above_threshold: 230,
            max_time_to_click_above_threshold: 400 
          }                
        ]
        formula_desc = {
          formula_sheet: 'reaction_time_demand.csv',
          formula_key: 'calculation'
        }
        @formula = TidepoolAnalyze::Utils::load_formula(formula_desc)
      end
    
      it 'calculates the reaction time for a simple and complex stage test' do
        formulator = ReactionTimeFormulator.new(@input_data, @formula)
        result = formulator.calculate_result
        result[:total_average_time_zscore].should_not be_nil
        result[:min_time].should == 210
        result[:max_time].should == 400
        result[:total_average_time].should == @input_data[0][:average_time_to_click] + @input_data[1][:average_time_to_click]
        result[:average_time].should == (@input_data[0][:average_time_to_click] + @input_data[1][:average_time_to_click])/2
      end
    end
  end
end