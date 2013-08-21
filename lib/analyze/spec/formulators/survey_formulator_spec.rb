require 'spec_helper'

module TidepoolAnalyze
  module Formulator

    describe SurveyFormulator do 
      before(:all) do
        @input_data = [[
          {:question_id=>"demand_1234", :answer=>5, :question_topic=>"demand"},
          {:question_id=>"productivity_1234", :answer=>3, :question_topic=>"productivity"},
          {:question_id=>"stress_1111", :answer=>2, :question_topic=>"stress"}
        ]]
        formula_desc = {
          formula_sheet: 'reaction_time_demand.csv',
          formula_key: 'calculation'
        }
        @formula = TidepoolAnalyze::Utils::load_formula(formula_desc)
      end
    
      it 'flattens all results to one array' do
        result = TidepoolAnalyze::Utils::merge_across_stages(@input_data)
        result.length.should == 3        
        result[2][:question_topic].should == 'stress'
      end

      it 'calculates the demand for demand topic questions' do
        formulator = SurveyFormulator.new(@input_data, @formula)
        result = formulator.calculate_result    
        result.length.should == 3
      end
    end
  end
end