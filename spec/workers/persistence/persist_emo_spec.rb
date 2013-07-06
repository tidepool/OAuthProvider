require 'spec_helper'

describe PersistBig5 do
  let(:user) { create(:user) }
  let(:game) { create(:game, user: user) }


  before(:all) do 
    @analysis_results = {
      emo: {
        score: {
          factors: {
            factor1: 0,
            factor2: 0,
            factor3: 0,
            factor4: 0,
            factor5: 0            
          },
          furthest_emotion: {
            emotion: "boredom",
            distance_standard: 1.8
          },
          closest_emotion: {
            emotion: "anger",
            distance_standard: 1.1
          },
          version: '2.0'
        },
        final_results: [
          {
            factors: {
              factor1: {
                weighted_total: 12,
                average: 5,
                average_zscore: 1.8,
                count: 3,
                mean: 1.2,
                std: 2
              },
              factor2: {
                weighted_total: 12,
                average: 5,
                average_zscore: 1.8,
                count: 3,
                mean: 1.2,
                std: 2
              },
              factor3: {
                weighted_total: 12,
                average: 5,
                average_zscore: 1.8,
                count: 3,
                mean: 1.2,
                std: 2
              },
              factor4: {
                weighted_total: 12,
                average: 5,
                average_zscore: 1.8,
                count: 3,
                mean: 1.2,
                std: 2
              },
              factor5: {
                weighted_total: 12,
                average: 5,
                average_zscore: 1.8,
                count: 3,
                mean: 1.2,
                std: 2
              }
            },
            furthest_emotion: {
              emotion: "boredom",
              distance_standard: 1.8
            },
            closest_emotion: {
              emotion: "anger",
              distance_standard: 1.1
            }
          }
        ],
      },
    }
  end

  it 'persists the emo results' do 

  end

end
