require 'spec_helper'

describe PersistBig5 do
  let(:user) { create(:user) }
  let(:game) { create(:game, user: user) }


  before(:all) do 
    @analysis_results = {
      big5: {
        score: {
          dimension: 'high_openness',
          dimension_values: {
            extraversion: 10,
            conscientiousness: 11,
            neuroticism: 22,
            openness: 35,
            agreeableness: 15,
            },
          low_dimension: 'extraversion',
          high_dimension: 'openness',
          adjust_by: 1,
          version: '2.0'
        },
        final_results: [
          {
                    extraversion: { weighted_total: 1,
                                    count: 1,
                                    average: 1 },
                    conscientiousness: {  weighted_total: 1,
                                          count: 1,
                                          average: 1 },
                    neuroticism: { weighted_total: 1,
                                   count: 1,
                                   average: 1 },
                    openness: { weighted_total: 1,
                                count: 1,
                                average: 1 },
                    agreeableness: { weighted_total: 1,
                                     count: 1,
                                     average: 1 }
          }, 
          {}
        ],
      },
    }
  end

  it 'persists the big5 results' do 
    persist_pr = PersistBig5.new
    persist_pr.persist(game, @analysis_results)
    updated_game = Game.find(game.id)
    updated_game.results.length.should == 1
    result = updated_game.results[0]
    result.type.should == 'Big5Result'
    result.score.should == {
       "adjust_by" => "1",
       "dimension" => "high_openness",
       "high_dimension" => "openness",
       "low_dimension" => "extraversion"
    }
    result.analysis_version.should == '2.0'
  end

  it 'persists the time_played and time_calculated' do
    persist_rt = PersistBig5.new
    persist_rt.persist(game, @analysis_results)
    updated_game = Game.find(game.id)
    updated_game.results.should_not be_nil
    updated_game.results.length.should == 1
    result = updated_game.results[0]
    result.time_played.should == updated_game.date_taken
    result.time_calculated.should > result.time_played
  end

end