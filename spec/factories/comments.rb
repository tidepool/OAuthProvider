# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    sequence(:text) {|n| "Awesome comment #{n}" }
  end
end
