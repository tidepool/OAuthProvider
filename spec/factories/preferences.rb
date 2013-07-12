# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :preference do
    data {{ 
      'daily_emotion' => 'true',
      'learn_emotion' => 'false'
    }}
  end
end
