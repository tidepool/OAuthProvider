require 'spec_helper'

module TidepoolAnalyze
  module ScoreGenerator

    describe 'Holland6 Score Spec' do
      before(:all) do
        @aggregate_results = {
            circles_test: {
                holland6: {
                    realistic: { average: 8 },
                    artistic: { average: 12 },
                    social: { average: 4 },
                    enterprising: { average: 3 },
                    investigative: { average: 1 },
                    conventional: { average: 5 }
                }
            }
        }
      end
      it 'should calculate the Holland6 score correctly' do
        holland6Score = Holland6Score.new
        result = holland6Score.calculate_score(@aggregate_results)
        result[:dimension].should_not be_nil
        result[:score].should_not be_nil
        result[:dimension].should == 'artistic'
        result[:score].should == {
          realistic: 8,
          artistic: 12,
          social: 4,
          enterprising: 3,
          investigative: 1,
          conventional: 5
        }
      end
    end
  end
end