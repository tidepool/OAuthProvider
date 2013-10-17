FactoryGirl.define do
  factory :result do 
    # intermediate_results "{\"message\":\"Hello World\"}" 
    # aggregate_results "{\"message\":\"Hello Aggregates\"}" 

    factory :old_result do 
      sequence(:time_played) { |n| Time.zone.now - 5.hours - (n * 1000) }
    end  

    factory :new_result do 
      sequence(:time_played) { |n| Time.zone.now - (n * 1000) }
    end    

    factory :daily_results do 
      sequence(:time_played) { |n| Time.zone.now - (n * 12.hours) }
    end

    factory :big5_result do 
      type 'Big5Result'
      calculations do 
        scores = IO.read(File.expand_path('../fixtures/scores.json', __FILE__))
        scores_json = JSON.parse scores, :symbolize_names => true
        {
          dimension_values: scores_json[:big5][:score],
          final_results: {}
        }
      end
    end

    factory :speed_archetype_rand_scores do 
      type 'SpeedArchetypeResult'
      sequence(:time_played) { |n| Time.zone.now - (n * 5.hours) }
      sequence(:score) do |n| 
        {
          "speed_score" => "#{rand 1000}"
        }
      end
    end

    factory :emo_intelligence_result do 
      type 'EmoIntelligenceResult'
      score do 
        {
               "corrects" => "6",
               "eq_score" => "3840",
             "incorrects" => "4",
           "time_elapsed" => "2100",
           "reported_mood"=>"sad",
        "instant_replays" => "7"
        }
      end
      calculations do 
        {
          "emo_groups" => {
             :happy=>{:corrects=>1, :incorrects=>0},
             :sad=>{:corrects=>1, :incorrects=>0},
             :angry=>{:corrects=>0, :incorrects=>0},
             :disgust=>{:corrects=>0, :incorrects=>0},
             :fear=>{:corrects=>1, :incorrects=>1},
             :surprise=>{:corrects=>0, :incorrects=>0}
          }
        }
      end

    end

    factory :speed_archetype_result do 
      type 'SpeedArchetypeResult'
      score do 
        {
          "speed_score" => "800",
          "average_time"=>"529",
          "average_time_simple"=>"340",
          "average_time_complex"=>"718",
          "fastest_time"=>"400",
          "slowest_time"=>"905",
          "description_id" => "2"
        }
      end
      calculations do 
        {
          "stage_data" => [
            { :test_type=>"simple",
              :test_duration=>17874,
              :average_time=>718,
              :slowest_time=>905,
              :fastest_time=>532,
              :total=>4,
              :total_correct=>2,
              :total_incorrect=>1,
              :total_missed=>1},
            { :test_type=>"complex",
              :test_duration=>17874,
              :average_time=>718,
              :slowest_time=>905,
              :fastest_time=>532,
              :total=>4,
              :total_correct=>2,
              :total_incorrect=>1,
              :total_missed=>1}
            ]
        }
      end
    end

    factory :prior_speed_archetypes do 
      type 'SpeedArchetypeResult'
      sequence(:time_played) { |n| Time.zone.now - (n * 12.hours) }
      score do 
        {
          "speed_score" => "800",
          "average_time"=>"529",
          "average_time_simple"=>"340",
          "average_time_complex"=>"718",
          "fastest_time"=>"400",
          "slowest_time"=>"905",
          "description_id" => "2"
        }
      end
    end

    factory :personality_result do 
      type 'PersonalityResult'
      score do 
        {
          "profile_description_id" => "2"
        }
      end
    end    
  end

  factory :personality do 
    big5_dimension "high_openness"
    big5_high "openness"
    big5_low "neuroticism"
    holland6_dimension "artistic"
    big5_score do 
      scores = IO.read(File.expand_path('../fixtures/scores.json', __FILE__))
      scores_json = JSON.parse scores, :symbolize_names => true
      scores_json[:big5][:score]
    end
    holland6_score do 
      scores = IO.read(File.expand_path('../fixtures/scores.json', __FILE__))
      scores_json = JSON.parse scores, :symbolize_names => true
      scores_json[:holland6][:score]
    end
  end

  factory :authentication do
    provider 'facebook'
    sequence(:uid) {|n| "1234#{n}" }
    oauth_token "123456"
    oauth_secret "232323"
    
    factory :fitbit do 
      provider 'fitbit'
      last_accessed Time.zone.now
      last_synchronized do 
        { 
          'activities' => (Time.zone.now - 2.days).to_s, 
          'sleeps' => (Time.zone.now - 2.hours).to_s,
          'foods' => (Time.zone.now - 5.days).to_s
        }
      end 
    end
    factory :fitbit_earlier do 
      provider 'fitbit'
      last_accessed Time.zone.now
      last_synchronized do 
        { 
          'activities' => (Time.zone.now - 2.days).to_s, 
          'sleeps' => (Time.zone.now - 2.days).to_s
        }
      end 
    end
    factory :fitbit_from_hongkong do 
      provider 'fitbit'
      last_accessed Time.zone.now.in_time_zone(8)
      last_synchronized do 
        { 
          'activities' => (Time.zone.now.in_time_zone(8) - 2.days).to_s, 
          'sleeps' => (Time.zone.now.in_time_zone(8) - 2.days).to_s
        }
      end 
      timezone_offset Time.zone.now.in_time_zone(8).utc_offset
    end
    
  end

  factory :definition do
    factory :profile_game do 
      persist_as_results "['profile']"
    end

    factory :other_game do 
      persist_as_results "['other']"
    end
  end

  factory :game do
    definition_id 1
    stages [{}, {}, {}, {}, {}, {}, {}]
    stage_completed -1
    status 'not_started'
    sequence(:date_taken) { |n| Time.zone.now - (n*1000) }

    factory :game_with_result do 
      after(:create) { |game| create(:result, game: game)}   
    end  
  end

  factory :user do
    sequence(:email) { |n| "spec_user#{n}@example.com" }
    password "12345678"
    password_confirmation "12345678"
    guest false
    admin false

    factory :admin do
      admin true
    end

    factory :guest do
      guest true
    end
  end
end
