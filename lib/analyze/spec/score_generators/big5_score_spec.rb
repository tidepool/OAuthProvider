require 'spec_helper'

module TidepoolAnalyze
  module ScoreGenerator
    describe 'Big5 Score Spec' do
      before(:all) do
        @aggregate_results = {
            image_rank: {
                big5: {
                    openness: { average: 10 },
                    agreeableness: { average: 3 },
                    conscientiousness: { average: 8 },
                    extraversion: { average: 6 },
                    neuroticism: { average: 1 }
                }
            },
            circles_test: {
                big5: {
                    openness: { average: 4 },
                    agreeableness: { average: 6 },
                    conscientiousness: { average: 2 },
                    extraversion: { average: 1 },
                    neuroticism: { average: 5 }
                }
            }
        }
      end
      it 'should calculate the Big5 score correctly' do
        big5Score = Big5Score.new
        result = big5Score.calculate_score(@aggregate_results)
        result[:dimension].should_not be_nil
        result[:score].should_not be_nil
        result[:friendly_name].should == 'Personality - Big5'
        result[:dimension].should == 'high_openness'
        result[:score].should == {
          openness: (10+4)/2,
          agreeableness: (3+6)/2,
          conscientiousness: (8+2)/2,
          extraversion: (6+1)/2,
          neuroticism: (1+5)/2          
        }
      end
    end
  end
end