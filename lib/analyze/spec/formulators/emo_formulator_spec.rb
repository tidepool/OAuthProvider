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
    
      it 'checks if a particular result needs to be flagged' do
        analyzer = EmoFormulator.new([], nil)
        aggregate_weighted_total = {
          factor1: { average_zscore: -1.2 },
          factor2: { average_zscore: -1.0 },
          factor3: { average_zscore: -1.0 },
          factor4: { average_zscore: -1.5 },
          factor5: { average_zscore: 0.2 }
        }
        flagged = analyzer.check_if_flagged(aggregate_weighted_total, :factor5)
        flagged.should == true

        aggregate_weighted_total = {
          factor1: { average_zscore: -1.2 },
          factor2: { average_zscore: -1.0 },
          factor3: { average_zscore: 1.0 },
          factor4: { average_zscore: -1.5 },
          factor5: { average_zscore: 0.2 }
        }
        flagged = analyzer.check_if_flagged(aggregate_weighted_total, :factor5)
        flagged.should == false

        aggregate_weighted_total = {
          factor1: { average_zscore: -1.2 },
          factor2: { average_zscore: -1.0 },
          factor3: { average_zscore: -1.0 },
          factor4: { average_zscore: -1.5 },
          factor5: { average_zscore: 0.4 }
        }
        flagged = analyzer.check_if_flagged(aggregate_weighted_total, :factor5)
        flagged.should == false
      end

    end

  end
end