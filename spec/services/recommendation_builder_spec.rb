require 'spec_helper'

describe RecommendationBuilder do
  let(:personality) { create(:personality, profile_description_id: 3) }
  let(:user_old_results) { create(:user, personality:personality) }
  let(:user_new_results) { create(:user, personality:personality) }
  let(:game_old) { create(:game, user: user_old_results) }
  let(:game_new) { create(:game, user: user_new_results) }
  let(:reaction_old_results) { create_list(:old_result, 10, game: game_old, user: user_old_results, type: 'ReactionTimeResult')}
  let(:emo_new_results) { create_list(:new_result, 5, game: game_new,  user: user_new_results, type: 'EmoResult')}

  it 'has the preferences setup action first, if it has not been set yet' do 
    pending
  end

  it 'has the emotions game result first if last game played was reaction_time and it was more than 5 hours ago' do
    reaction_old_results
    builder = RecommendationBuilder.new(user_old_results)

    recos = builder.recommendations
    recos.length.should == 4
    recos[0].title.should == 'Game'
    recos[0].link.should == '#game/emotions'
  end 

  it 'does not have any game recommendations, if games were played less than 5 hours ago' do 
    emo_new_results
    builder = RecommendationBuilder.new(user_new_results)
    recos = builder.recommendations
    recos.length.should == 3
    recos[0].title.should_not == 'Game'
  end
end