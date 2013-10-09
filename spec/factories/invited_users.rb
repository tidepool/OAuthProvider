# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invited_user do

    factory :invited_users do 
      sequence(:invited_email) { |n| "spec_user#{n}@example.com" }
    end
  end
end
