class SpeedAggregateResult < AggregateResult
  include TimeZoneCalculations

  store_accessor :high_scores, :all_time_best
  store_accessor :high_scores, :daily_best
  store_accessor :high_scores, :daily_average
  store_accessor :high_scores, :daily_total
  store_accessor :high_scores, :daily_data_points
  store_accessor :high_scores, :current_day
  store_accessor :high_scores, :last_description_id

  def all_time_best=(value)
    super(value.to_i)
  end

  def all_time_best
    super.to_i
  end

  def daily_best=(value)
    super(value.to_i)
  end

  def daily_best
    super.to_i
  end
    
  def active_model_serializer
    SpeedAggregateResultSerializer
  end

  def self.create_from_analysis(game, analysis_results, time, existing_result = nil)
    return nil unless game && game.user_id
    return nil unless analysis_results && analysis_results[:reaction_time2] && analysis_results[:reaction_time2][:score]

    timezone_offset = analysis_results[:reaction_time2][:timezone_offset].to_i

    result = existing_result
    if result.nil?
      result = AggregateResult.create(type: 'SpeedAggregateResult', user_id: game.user_id)
      result.initialize_scores
      result.initialize_high_scores(result.time_from_offset(time, timezone_offset))
    end

    result.initialize_high_scores(result.time_from_offset(time, timezone_offset)) if result.high_scores.nil?
 
    score = analysis_results[:reaction_time2][:score]
 
    # Update the mean and sd
    new_simple = result.update_mean_and_sd("simple", score[:average_time_simple])
    new_complex = result.update_mean_and_sd("complex", score[:average_time_complex])
   
    # Update the circadian results
    hour = result.time_from_offset(time, timezone_offset).hour
    circadian = result.scores["circadian"]
    circadian[hour.to_s] = result.update_circadian(score, hour)

    # Update the high scores
    result.high_scores = result.update_high_scores(score[:speed_score].to_i, time, timezone_offset)

    # Get the weekly results
    day = result.time_from_offset(time, timezone_offset).wday
    weekly = result.scores["weekly"]
    if weekly.nil? || weekly.empty?
      # This is for existing users prior to the introduction of this feature.
      weekly = result.initialize_weekly_for_existing_user(game.user_id) 
    end

    # Update the trend and weekly
    trend = result.calculate_trend(score[:speed_score], weekly[day]['average_speed_score'])
    weekly[day] = result.update_weekly(weekly[day], score, result.daily_average)
    
    result.scores = {
      "simple" => new_simple,
      "complex" => new_complex,
      "circadian" => circadian,
      "weekly" => weekly,
      "trend" => trend
    }
    result.save ? result : nil
  end

  def initialize_scores
    circadian = initialize_circadian
    weekly = initialize_weekly
    self.scores = {
      "simple" => {
        "sums" => 0.0,
        "total_results" => 0,
        "mean" => 0.0,
        "sd" => 0.0
      },
      "complex" => {
        "sums" => 0.0,
        "total_results" => 0,
        "mean" => 0.0,
        "sd" => 0.0
      },
      "circadian" => circadian,
      "weekly" => weekly,
      "trend" => 0.0,
      "last_speed_score" => 0
    }
  end

  def initialize_circadian
    circadian = {}
    (0...24).each do |hour|
      circadian[hour.to_s] = {
        "speed_score" => 0,
        "fastest_time" => 100000,
        "slowest_time" => 0,
        "average_time_simple" => 100000,
        "average_time_complex" => 100000,
        "times_played" => 0        
      }
    end
    circadian
  end

  def initialize_weekly
    weekly = []
    (0..6).each do |i|
      weekly << {
        'speed_score' => 0,
        'average_speed_score' => 0.0,
        'fastest_time' => 1000000,
        'slowest_time' => 0,
        'data_points' => 0
      }
    end
    weekly
  end

  def initialize_weekly_for_existing_user(user_id)
    weekly = initialize_weekly
    prior_yday = 232  # Sometime before we launched...
    total_speed_score = 0
    data_points = 0
    average_speed_score = 0
    previous_results = Result.where(user_id: user_id, type: 'SpeedArchetypeResult').order(:time_played).to_a
    previous_results.each do | result |
      yday = result.time_played.yday
      # This algorithm relies on results to be sorted.
      if yday == prior_yday
        data_points += 1
        total_speed_score += result.speed_score.to_i
        average_speed_score = total_speed_score / data_points
      else
        prior_yday = yday
        data_points = 1
        total_speed_score = result.speed_score.to_i
        average_speed_score = total_speed_score
      end
      day = result.time_played.wday
      score = {
        speed_score: result.speed_score,
        fastest_time: result.fastest_time,
        slowest_time: result.slowest_time
      }
      weekly[day] = update_weekly(weekly[day], score, average_speed_score)
    end
    weekly
  end

  def find_last_speed_score(user_id)
    last_result = Result.where(user_id: user_id, type: 'SpeedArchetypeResult').order('time_played').last
    speed_score = 0
    if last_result
      speed_score = last_result.speed_score.to_i
    end
    speed_score
  end

  def update_weekly(weekly, score, average_speed_score)   
    speed_score = weekly["speed_score"]
    speed_score = score[:speed_score].to_i if score[:speed_score].to_i > weekly["speed_score"].to_i 

    fastest_time = weekly["fastest_time"]
    fastest_time = score[:fastest_time].to_i if score[:fastest_time].to_i < weekly["fastest_time"].to_i 

    slowest_time = weekly["slowest_time"]
    slowest_time = score[:slowest_time].to_i if score[:slowest_time].to_i > weekly["slowest_time"].to_i 

    data_points = weekly["data_points"]
    data_points += 1 

    {
      "speed_score" => speed_score,
      "average_speed_score" => average_speed_score,
      "fastest_time" => fastest_time,
      "slowest_time" => slowest_time,
      "data_points" => data_points
    }
  end

  def update_circadian(score, hour)
    circadian = self.scores["circadian"][hour.to_s]

    speed_score = circadian["speed_score"]
    speed_score = score[:speed_score] if score[:speed_score] > circadian["speed_score"] 
      
    fastest_time = circadian["fastest_time"]
    fastest_time = score[:fastest_time] if score[:fastest_time] < circadian["fastest_time"]

    slowest_time = circadian["slowest_time"]
    slowest_time = score[:slowest_time] if score[:slowest_time] > circadian["slowest_time"]

    average_time_simple = circadian["average_time_simple"]
    average_time_simple = score[:average_time_simple] if score[:average_time_simple] < circadian["average_time_simple"]

    average_time_complex = circadian["average_time_complex"]
    average_time_complex = score[:average_time_complex] if score[:average_time_complex] < circadian["average_time_complex"]

    times_played = circadian["times_played"]
    times_played += 1 

    {
      "speed_score" => speed_score,
      "fastest_time" => fastest_time,
      "slowest_time" => slowest_time,
      "average_time_simple" => average_time_simple,
      "average_time_complex" => average_time_complex,
      "times_played" => times_played
    }
  end

  # prev_mean = m;
  #  n = n + 1;
  #  m = m + (x-m)/n;
  #  S = S + (x-m)*(x-prev_mean);
  # std = sqrt(S/n)
  # http://dsp.stackexchange.com/questions/811/determining-the-mean-and-standard-deviation-in-real-time
  def update_mean_and_sd(score_type, new_score)
    prev_mean = self.scores[score_type]["mean"]
    total_results = self.scores[score_type]["total_results"] + 1

    mean = prev_mean + (new_score - prev_mean) / total_results
    sums = self.scores[score_type]["sums"] + (new_score - mean) * (new_score - prev_mean)
    sd = Math.sqrt(sums/total_results)

    {
      "sums" => sums, 
      "total_results" => total_results,
      "mean" => mean,
      "sd" => sd
    }
  end

end