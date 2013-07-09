require 'spec_helper'

describe PersistPersonality do
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

  it 'persists the personality results' do 
    persist_pr = PersistPersonality.new
    persist_pr.persist(game, @analysis_results)
    user.personality.should_not be_nil

    updated_game = Game.find(game.id)
    updated_game.results.length.should == 1
    result = updated_game.results[0]
    result.type.should == 'PersonalityResult'
    result.score.should == {
      "name" => "The Swiss Army Knife",
      "one_liner" => "**The Swiss Army Knife** welcomes new and complex problems and invents offers concrete solutions through immediate action.", 
      "logo_url" => "The-Swiss-Army-Knife.png",
      "profile_description_id" => "13"
    }
    result.analysis_version.should == '2.0'
  end

  it 'persists the time_played and time_calculated' do
    persist_rt = PersistPersonality.new
    persist_rt.persist(game, @analysis_results)
    updated_game = Game.find(game.id)
    updated_game.results.should_not be_nil
    updated_game.results.length.should == 1
    result = updated_game.results[0]
    result.time_played.should == updated_game.date_taken
    result.time_calculated.should > result.time_played
  end
end