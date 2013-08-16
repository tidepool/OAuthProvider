require 'spec_helper'

module TidepoolAnalyze
  module Formulator

    describe ReactionTime2Formulator do 
      before(:all) do
        @input_data = [
          {
            :test_type => "simple",
            :test_duration => 17874,
            :average_time => 718,
            :slowest_time => 905,
            :fastest_time => 532,
            :total => 4,
            :total_correct => 2,
            :total_incorrect => 1,
            :total_missed => 1
          },
          {
            :test_type => "complex",
            :test_duration => 17874,
            :average_time => 718,
            :slowest_time => 905,
            :fastest_time => 532,
            :total => 4,
            :total_correct => 2,
            :total_incorrect => 1,
            :total_missed => 1
          }                
        ]
        formula_desc = {
          formula_sheet: 'reaction_time_demand.csv',
          formula_key: 'calculation'
        }
        @formula = TidepoolAnalyze::Utils::load_formula(formula_desc)
      end
    
      it 'calculates the reaction time for a simple and complex stage test' do
        formulator = ReactionTime2Formulator.new(@input_data, @formula)
        result = formulator.calculate_result
        result[:average_time].should == (@input_data[0][:average_time] + @input_data[1][:average_time])/2
        result[:slowest_time].should == 905
        result[:fastest_time].should == 532
        result[:average_time_simple].should == @input_data[0][:average_time]
        result[:average_time_complex].should == @input_data[1][:average_time] 
        result[:stage_data].should == @input_data
      end
    end
  end
end