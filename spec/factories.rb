FactoryGirl.define do
  factory :game do
    definition_id 1
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
