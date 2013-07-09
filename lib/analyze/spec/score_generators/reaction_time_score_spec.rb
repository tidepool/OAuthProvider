require 'spec_helper'

module TidepoolAnalyze
  module ScoreGenerator

    describe ReactionTimeScore do
      before(:all) do
        @input_data = [
          average_time_zscore: -2.3,
          average_time: 230,
          min_time: 210,
          max_time: 250
        ]
      end
      it 'should calculate the reaction_time score correctly' do
        reaction_time_score = ReactionTimeScore.new
        result = reaction_time_score.calculate_score(@input_data)
        result[:average_time].should == 230
        result[:fastest_time].should == 210
        result[:slowest_time].should == 250
      end
    end
  end
end