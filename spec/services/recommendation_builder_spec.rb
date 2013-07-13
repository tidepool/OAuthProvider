require 'spec_helper'

describe RecommendationBuilder do

  let(:personality) { create(:personality, profile_description_id: 3) }
  let(:user) { create(:user, personality:personality) } 
  let(:game) { create(:game, user: user) }
  let(:preference) { create(:preference, user: user, type: 'TrainingPreference')}

  describe 'first time, user has no preferences' do 
    let(:user_no_preferences) { create(:user, personality:personality) }

    it 'has the preferences setup action first, if it has not been set yet' do 
      builder = RecommendationBuilder.new(user_no_preferences)
      recos = builder.recommendations
      recos.length.should == 5
      recos[0].link_type.should == 'TidePoolPreferences'
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
  end

  describe 'both games played less than 5 hours ago' do 
    let(:emo_new_results) { create_list(:new_result, 2, game: game,  user: user, type: 'EmoResult')}
    let(:reaction_new_results) { create_list(:new_result, 2, game: game,  user: user, type: 'ReactionTimeResult')}

    it 'does not have any game recommendations' do 
      emo_new_results
      reaction_new_results
      preference

      builder = RecommendationBuilder.new(user)
      recos = builder.recommendations
      recos.length.should == 3
      recos[0].link_type.should_not == 'TidePoolGame'
    end
  end

  describe 'both games not played for 5 hours, emotions was the last game played' do 
    let(:emo_old_results) { create_list(:old_result, 2, game: game,  user: user, type: 'EmoResult') }

    it 'has a reaction_time game result' do
      emo_old_results
      preference

      builder = RecommendationBuilder.new(user)
      recos = builder.recommendations
      recos.length.should == 4
      recos[0].link_type.should == 'TidePoolGame'
      recos[0].link.should == '#game/reaction_time'
    end
  end

  describe 'both games not played for 5 hours, reaction was the last game played and emo before that' do 
    let(:reaction_old_results) { create_list(:old_result, 2, game: game,  user: user, type: 'ReactionTimeResult') }
    let(:emo_old_results) { create_list(:old_result, 2, game: game,  user: user, type: 'EmoResult') }

    it 'has a emotions game result' do
      reaction_old_results
      emo_old_results
      preference

      builder = RecommendationBuilder.new(user)
      recos = builder.recommendations
      recos.length.should == 4
      recos[0].link_type.should == 'TidePoolGame'
      recos[0].link.should == '#game/emotions'
    end
  end
end