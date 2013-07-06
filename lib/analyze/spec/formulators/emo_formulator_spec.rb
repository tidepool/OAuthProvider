require 'spec_helper'

module TidepoolAnalyze
  module Formulator

    describe ElementFormulator do 
      before(:all) do
        @input_data = [
          {
            :trait1 => "boredom",
            :size => 3,
            :distance_standard => 2,
            :overlap => 0.34, 
            :maps_to => 'factor5'
          },
          {
            :trait1 => "anger",
            :size => 3,
            :distance_standard => 2,
            :overlap => 0.34, 
            :maps_to => 'factor2'
          }
        ]
        formula_desc = {
          formula_sheet: 'emo_circles.csv',
          formula_key: 'name'
        }
        @formula = TidepoolAnalyze::Utils::load_formula(formula_desc)
      end
    
      it 'calculates' do

      end

    end

  end
end