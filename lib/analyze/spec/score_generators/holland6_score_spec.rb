require 'spec_helper'

module TidepoolAnalyze
  module ScoreGenerator

    describe Holland6Score do
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
      it 'calculates the Holland6 score correctly' do
        holland6_score = Holland6Score.new
        result = holland6_score.calculate_score(@aggregate_results)
        result[:score].should_not be_nil
        result[:dimension].should == 'artistic'
      end
    end
  end
end