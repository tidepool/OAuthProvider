require 'spec_helper'

describe PersistPersonality do
  let(:user) { create(:user) }
  let(:game) { create(:game, user: user) }


  before(:all) do 
    @analysis_results = {
      big5: {
        score: {
          fastest_time: 455,
          slowest_time: 600, 
          average_time: 520
        },
        final_results: [
          {
            total_average_time_zscore: -3.2,
            total_average_time: 1055,
            average_time: 520,
            min_time: 455,
            max_time: 600
          },
          {
            demand: 50
          }
        ],
        version: '2.0'
      }
    }
  end

  it 'persists the reaction_time results' do 
    persist_pr = PersistPersonality.new

  end
end