require 'spec_helper'

module TidepoolAnalyze
  module ScoreGenerator
    describe 'Big5 Score Spec' do
      before(:all) do
        @aggregate_results = [
            {
              openness: { average: 10 },
              agreeableness: { average: 3 },
              conscientiousness: { average: 8 },
              extraversion: { average: 6 },
              neuroticism: { average: 1 }
            },
            {
              openness: { average: 4 },
              agreeableness: { average: 6 },
              conscientiousness: { average: 2 },
              extraversion: { average: 1 },
              neuroticism: { average: 5 }
            }
        ]
      end
      it 'should calculate the Big5 score correctly' do
        big5Score = Big5Score.new
        result = big5Score.calculate_score(@aggregate_results)
        result[:dimension].should == 'high_openness'
        result[:low_dimension].should == :extraversion
        result[:score].should_not be_nil
      end
    end
  end
end