# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :activity do
    provider 'fitbit'
    date_recorded do 
      Date.current
    end
    data do 
      {
        "very_active_minutes" => "30",
        "floors" => "5",
        "steps" => "2000",
        "distance" => "4.24",
        "calories" => "1978"
      }
    end
    goals do 
      {
        "floors_goal" => "10",
        "steps_goal" => "8000",
        "distance_goal" => "5.0",
        "calories_goal" => "2184"   
      }   
    end

    factory :activities do 
      sequence(:date_recorded) { |n| Date.current - n.days }
    end
  end
end
