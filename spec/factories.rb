FactoryGirl.define do
  factory :result do 
    intermediate_results "{\"message\":\"Hello World\"}"        
  end

  factory :game do
    definition_id 1
    status 'not_started'
    sequence(:date_taken) { |n| Time.zone.now - (n*1000) }
  end

  factory :user do
    sequence(:email) { |n| "spec_user#{n}@example.com" }
    password "12345678"
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
