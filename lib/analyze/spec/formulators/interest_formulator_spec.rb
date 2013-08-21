require 'spec_helper'

module TidepoolAnalyze
  module Formulator

    describe InterestFormulator do 
      before(:all) do
        @input_data = [
          {
            :realistic=>{:word_count=>3, :symbol_count=>1},
            :artistic=>{:word_count=>0, :symbol_count=>0},
            :social=>{:word_count=>2, :symbol_count=>0},
            :enterprising=>{:word_count=>0, :symbol_count=>2},
            :investigative=>{:word_count=>1, :symbol_count=>0},
            :conventional=>{:word_count=>1, :symbol_count=>0}
          }
        ]
      end
    
      it 'calculates the big5 from image elements' do
        interest_formulator = InterestFormulator.new(@input_data, nil)
        result = interest_formulator.calculate_result
        result.should_not be_nil
        result.length.should == 6
        result.should == {
          :realistic=>4,
          :artistic=>0,
          :social=>2,
          :enterprising=>2,
          :investigative=>1,
          :conventional=>1
        }
      end
    end
  end
end