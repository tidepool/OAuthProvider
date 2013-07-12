require 'spec_helper'

describe RecommendationBuilder do
  let(:personality) { create(:personality, profile_description_id: 3) }
  let(:user_no_preferences) { create(:user, personality:personality) }

  let(:user_old_results) { create(:user, personality:personality) }
  let(:user_new_results) { create(:user, personality:personality) }
  let(:game_old) { create(:game, user: user_old_results) }
  let(:game_new) { create(:game, user: user_new_results) }
  let(:reaction_old_results) { create_list(:old_result, 10, game: game_old, user: user_old_results, type: 'ReactionTimeResult')}
  let(:emo_new_results) { create_list(:new_result, 5, game: game_new,  user: user_new_results, type: 'EmoResult')}

  let(:preference1) { create(:preference, user: user_old_results, type: 'TrainingPreference')}
  let(:preference2) { create(:preference, user: user_new_results, type: 'TrainingPreference')}



  it 'has the preferences setup action first, if it has not been set yet' do 
    builder = RecommendationBuilder.new(user_no_preferences)
    recos = builder.recommendations
    recos.length.should == 4
    recos[0].title.should == 'Preferences'
  end

  it 'can select random numbers that are not repeated' do 
    builder = RecommendationBuilder.new(user_no_preferences)
    nums = builder.generate_non_repeating_random(10, 0...11)

    nums_so_far = {}
    repeated = false
    nums.each do |num|
      if nums_so_far.key?(num.to_s)
        repeated = true
        break;
      end
      nums_so_far[num.to_s] = num
    end
    repeated.should == false
  end

  it 'has the emotions game result first if last game played was reaction_time and it was more than 5 hours ago' do
    reaction_old_results
    preference1
    builder = RecommendationBuilder.new(user_old_results)
    recos = builder.recommendations
    recos.length.should == 4
    recos[0].title.should == 'Game'
    recos[0].link.should == '#game/emotions'
  end 

  it 'does not have any game recommendations, if games were played less than 5 hours ago' do 
    emo_new_results
    preference2

    builder = RecommendationBuilder.new(user_new_results)
    recos = builder.recommendations
    recos.length.should == 3
    recos[0].title.should_not == 'Game'
  end
end