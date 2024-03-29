require 'spec_helper'

describe PersistHolland6 do
  let(:user) { create(:user) }
  let(:game) { create(:game, user: user) }


  before(:all) do 
    @analysis_results = {
      holland6: {
        score: {
          dimension: 'realistic',
          dimension_values: {
            realistic: 50,
            artistic: 10,
            social: 23,
            investigative: 34,
            enterprising: 12,
            conventional: 40            
            },
          adjust_by: 1,
          version: '2.0'
        }, 
        final_results: [
          {
            realistic: { weighted_total: 1,
                            count: 1,
                            average: 1 },
            artistic: {  weighted_total: 1,
                                  count: 1,
                                  average: 1 },
            social: { weighted_total: 1,
                           count: 1,
                           average: 1 },
            investigative: { weighted_total: 1,
                        count: 1,
                        average: 1 },
            enterprising: { weighted_total: 1,
                             count: 1,
                             average: 1 },
            conventional: { weighted_total: 1,
                            count: 1,
                            average: 1 }
          }      
        ],
      }
    }
  end

  it 'persists the holland6 results' do 
    persist_pr = PersistHolland6.new
    persist_pr.persist(game, @analysis_results)

    updated_game = Game.find(game.id)
    updated_game.results.length.should == 1
    result = updated_game.results[0]
    result.type.should == 'Holland6Result'
    result.user_id.should == user.id
    result.score.should == {
       "adjust_by" => "1",
       "dimension" => "realistic",
    }
    result.analysis_version.should == '2.0'
  end

  it 'persists the time_played and time_calculated' do
    persist_rt = PersistHolland6.new
    persist_rt.persist(game, @analysis_results)
    updated_game = Game.find(game.id)
    updated_game.results.should_not be_nil
    updated_game.results.length.should == 1
    result = updated_game.results[0]
    result.time_played.should == updated_game.date_taken
    result.time_calculated.should > result.time_played
  end
end