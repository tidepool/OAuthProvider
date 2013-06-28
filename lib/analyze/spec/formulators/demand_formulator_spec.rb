require 'spec_helper'

module TidepoolAnalyze
  module Formulator

    describe DemandFormulator do 
      before(:all) do
        @input_data = [
          [ 
            { 
              question_id: 'demand_question1',
              question_topic: 'demand', 
              answer: 5
            },
            {
              question_id: 'foo_question2', 
              question_topic: 'foo',
              answer: { 'bar' => '0'}
            }      
          ],
          [
            {
              question_id: 'test_question2', 
              question_topic: 'test',
              answer: { 'bar' => '0'}
            }      
          ]
        ]
        formula_desc = {
          formula_sheet: 'reaction_time_demand.csv',
          formula_key: 'calculation'
        }
        @formula = TidepoolAnalyze::Utils::load_formula(formula_desc)
      end
    
      it 'flattens all results to one array' do
        formulator = DemandFormulator.new(@input_data, @formula)
        result = formulator.flatten_results_to_array(@input_data)

        result.length.should == 3
        result[2][:question_topic].should == 'test'
      end

      it 'calculates the demand for demand topic questions' do
        formulator = DemandFormulator.new(@input_data, @formula)
        result = formulator.calculate_result
        result[:demand].should_not be_nil
      end
    end
  end
end