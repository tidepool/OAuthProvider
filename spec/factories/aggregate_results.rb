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
    high_scores do 
      {
        "all_time_best" => 2400,
        "daily_best" => 1600,
        "current_day" => Time.zone.now.to_s,
        "last_value" => 8
      }
    end 
    
    factory :emo_aggregate_result do 
      type 'EmoAggregateResult'
      scores do 
        {
          sad: 
            {
              happy: { corrects: 6, incorrects: 2 },
              sad: { corrects: 4, incorrects: 1 },
              angry: { corrects: 1, incorrects: 0 }, 
              disgust: { corrects: 1, incorrects: 2 }, 
              fear: { corrects: 3, incorrects: 1 },
              surprise: {corrects: 0, incorrects: 3 }              
            }
        }
      end
      high_scores do 
        {
          "all_time_best" => 4000,
          "daily_best" => 1600,
          "current_day" => Time.zone.now.to_s, 
          "daily_data_points" => 1,
          "last_value" => 1800
        }        
      end
    end

    factory :attention_aggregate_result do 
      type 'AttentionAggregateResult'
      scores do 
        rand_gen = Random.new
        weekly = (0..6).map do |i|
          {
            'score' => rand_gen.rand(100..4000),
            'average_score' => rand_gen.rand(500.0..3000.0),
            'data_points' => rand_gen.rand(1..10)
          }
        end
        circadian = {}
        (0...24).each do |hour|
          circadian[hour.to_s] = {
            "score" => rand_gen.rand(100..4000),
            "times_played" => rand_gen.rand(1..10)        
          }
        end
        {
          "circadian" => circadian,
          "weekly" => weekly,
          "trend" =>  0.5
        }
      end
      high_scores do 
        {
          "all_time_best" => 2500,
          "daily_best" => 1600,
          "current_day" => Time.zone.now.to_s, 
          "daily_data_points" => 1,
          "last_value" => 1800
        }        
      end
    end

  end
end