FactoryGirl.define do
  factory :result do 
    intermediate_results "{\"message\":\"Hello World\"}" 
    aggregate_results "{\"message\":\"Hello Aggregates\"}"       
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
  end

  factory :definition do
    factory :profile_game do 
      calculates "['profile']"
    end

    factory :other_game do 
      calculates "['other']"
    end
  end

  factory :game do
    definition_id 1
    status 'not_started'
    sequence(:date_taken) { |n| Time.zone.now - (n*1000) }
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
