# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sleep do
    provider 'fitbit'
    date_recorded do 
      Date.current
    end
    data do 
      {
        "total_minutes_asleep" => "365", 
        "total_minutes_in_bed" => "400"
      }
    end

    factory :sleeps do 
      sequence(:date_recorded) { |n| Date.current - n.days }
    end
  end
end
