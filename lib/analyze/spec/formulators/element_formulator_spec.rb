require 'spec_helper'

module TidepoolAnalyze
  module Formulator

    describe ElementFormulator do 
      before(:all) do
        @input_data = [ { 'animal' => 10, 'adult' => 5, 'alone' => 7, 'abstraction' => 15 },
                        { 'sunset' => 10, 'adult' => 2, 'male' => 7, 'abstraction' => 6 } ]
        formula_desc = {
          formula_sheet: 'elements.csv',
          formula_key: 'name'
        }
        @formula = TidepoolAnalyze::Utils::load_formula(formula_desc)
      end
    
      it 'calculates the big5 from image elements' do
        element_formulator = ElementFormulator.new(@input_data, @formula)
        result = element_formulator.calculate_result
        result.should_not be_nil
        result.length.should == 5
        result[:extraversion].should_not be_nil
        result[:conscientiousness].should_not be_nil
        result[:neuroticism].should_not be_nil
        result[:openness].should_not be_nil
        result[:agreeableness].should_not be_nil       
      end

    end
  end
end
