# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :activity_record do
    sequence(:performed_at) { |n| Time.zone.now - (n*1000) }
    
    factory :make_friends_activity, :class => 'MakeFriendsActivity' do 
      raw_data do 
        {
          'friend_name' => 'John Doe',
          'friend_id' => '1234'
        }
      end    
    end

    factory :high_score_activity, :class => 'HighScoreActivity' do 
      raw_data do 
        {
          'score' => 4000,
          'game_name' => 'snoozer'
        }
      end
    end

  end
end
