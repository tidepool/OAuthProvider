require 'spec_helper'

module TidepoolAnalyze
  module ScoreGenerator

    describe 'Holland6 Score Spec' do
      before(:all) do
        @aggregate_results = [
          {
            realistic: { average: 8 },
            artistic: { average: 12 },
            social: { average: 4 },
            enterprising: { average: 3 },
            investigative: { average: 1 },
            conventional: { average: 5 }
          }
        ]
      end
      it 'should calculate the Holland6 score correctly' do
        holland6Score = Holland6Score.new
        result = holland6Score.calculate_score(@aggregate_results)
        result[:score].should_not be_nil
        result[:dimension].should == 'artistic'
      end
    end
  end
end