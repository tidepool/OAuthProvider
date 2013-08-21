require 'spec_helper'

describe PersistSpeedArchetype do
  let(:user) { create(:user) }
  let(:game) { create(:game, user: user) }
  let(:personality) { create(:personality, user: user) }

  before(:all) do 
    @analysis_results = {
      reaction_time2: {
        score: {
          :speed_archetype=>"dog",
          :average_time=>529,
          :average_time_simple=>340,
          :average_time_complex=>718,
          :fastest_time=>400,
          :slowest_time=>905,
          :version => "2.0"
        },
        final_results: [
          {
            :average_time=>529,
            :average_time_simple=>340,
            :average_time_complex=>718,
            :fastest_time=>400,
            :slowest_time=>905
          }
        ]
      }
    }
  end

  it 'persists the speed_archetype results' do 
    user
    personality
    persist_rt = PersistSpeedArchetype.new
    persist_rt.persist(game, @analysis_results)

    updated_game = Game.find(game.id)
    updated_game.results.should_not be_nil
    updated_game.results.length.should == 1
    result = updated_game.results[0]
    result.user_id.should == user.id
    result.type.should == 'SpeedArchetypeResult'
    result.score.should == {
      # "speed_archetype"=>"dog",
      "average_time"=>"529",
      "average_time_simple"=>"340",
      "average_time_complex"=>"718",
      "fastest_time"=>"400",
      "slowest_time"=>"905",
      "reaction_time_description_id" => "24"
    }
    result.analysis_version.should == '2.0'
  end

  it 'persists the speed_archetype results even if the personality does not exist' do 
    # This is temporary, if the personality test is not taken, 
    # we just pick high_extraversion as the big5_dimension

    persist_rt = PersistSpeedArchetype.new
    persist_rt.persist(game, @analysis_results)

    updated_game = Game.find(game.id)
    updated_game.results.should_not be_nil
    updated_game.results.length.should == 1
    result = updated_game.results[0]
    result.type.should == 'SpeedArchetypeResult'
    desc = ReactionTimeDescription.find(result.reaction_time_description_id)
    desc.big5_dimension.should == 'high_extraversion'
    result.analysis_version.should == '2.0'
  end
end