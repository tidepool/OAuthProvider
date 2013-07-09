require 'spec_helper'

module TidepoolAnalyze
  module ScoreGenerator

    describe CapacityScore do
      before(:all) do
        @input_data = []
      end
    

      it 'calculates capacity score correctly' do
        capacity_score = CapacityScore.new
        result = capacity_score.calculate_score(@input_data)
        
        
      end
    end
  end
end

