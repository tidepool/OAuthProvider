# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :aggregate_result do
    type 'SpeedAggregateResult'
    scores do 
      {
        "simple" => {
                     "sums" => 0.0,
            "total_results" => 1,
                     "mean" => 340.0,
                       "sd" => 0.0
          },
          "complex" => {
                     "sums" => 0.0,
            "total_results" => 1,
                     "mean" => 718.0,
                       "sd" => 0.0
          },
          "circadian" => {
             "0" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
             "1" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
             "2" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
             "3" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
             "4" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
             "5" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
             "6" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
             "7" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
             "8" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
             "9" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
            "10" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
            "11" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
            "12" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
            "13" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
             "3" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
             "4" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
             "5" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
             "6" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
             "7" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
             "8" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
             "9" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
            "10" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
            "11" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
            "12" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
            "13" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
            "14" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
            "15" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
            "16" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
            "17" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
            "18" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
            "19" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
            "20" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
            "21" => {
                       "speed_score" => 800,
                      "fastest_time" => 400,
                      "slowest_time" => 905,
               "average_time_simple" => 340,
              "average_time_complex" => 718,
                      "times_played" => 1
            },
            "22" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            },
            "23" => {
                       "speed_score" => 0,
                      "fastest_time" => 100000,
                      "slowest_time" => 0,
               "average_time_simple" => 100000,
              "average_time_complex" => 100000,
                      "times_played" => 0
            }
          }
      }
    end
  end
end