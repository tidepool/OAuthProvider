class SpeedAggregateResult < AggregateResult
  store_accessor :high_scores, :all_time_best
  store_accessor :high_scores, :daily_best
  store_accessor :high_scores, :current_day

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

  def self.create_from_analysis(game, analysis_results, existing_result = nil)
    return nil unless game && game.user_id
    return nil unless analysis_results && analysis_results[:reaction_time2] && analysis_results[:reaction_time2][:score]

    result = existing_result
    if result.nil?
      result = AggregateResult.create(type: 'SpeedAggregateResult', user_id: game.user_id)
      result.initialize_scores
      result.initialize_high_scores
    end

    if result.high_scores.nil?
      result.initialize_high_scores
    end

    score = analysis_results[:reaction_time2][:score]
    new_simple = result.update_mean_and_sd("simple", score[:average_time_simple])
    new_complex = result.update_mean_and_sd("complex", score[:average_time_complex])

    hour = Time.zone.now.hour
    circadian = result.scores["circadian"]
    circadian[hour.to_s] = result.update_circadian(score, hour)

    day = Time.zone.now.wday
    weekly = result.scores["weekly"]
    weekly = result.initialize_weekly if weekly.nil?

    weekly[day] = result.update_weekly(weekly[day], score)

    result.high_scores = result.update_high_scores(score)
    result.scores = {
      "simple" => new_simple,
      "complex" => new_complex,
      "circadian" => circadian,
      "weekly" => weekly
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
      "weekly" => weekly
    }
  end

  def initialize_high_scores 
    self.high_scores = {
      "all_time_best" => 0,
      "daily_best" => 0,
      "current_day" => Time.zone.now.to_s
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
        'fastest_time' => 1000000,
        'slowest_time' => 0,
        'data_points' => 0
      }
    end
    weekly
  end


  def update_high_scores(score)
    all_time_best = update_all_time_best(score)
    today = Time.zone.now    
    daily_best = update_daily_best(score, today)
    
    {
      all_time_best: all_time_best,
      daily_best: daily_best,
      current_day: today.to_s
    }
  end

  def update_all_time_best(score)
    best_score = self.all_time_best
    best_score = score[:speed_score] if best_score.nil? || score[:speed_score] > best_score
    best_score
  end

  def update_daily_best(score, day)
    stored_year_day = Time.zone.parse(self.high_scores[:current_day]).yday
    year_day = day.yday

    best_score = score[:speed_score]
    if stored_year_day == year_day
      best_score = self.daily_best
      best_score = score[:speed_score] if best_score.nil? || score[:speed_score] > best_score
    end
    best_score
  end

  def update_weekly(weekly, score)   
    speed_score = weekly["speed_score"]
    speed_score = score[:speed_score] if score[:speed_score] > weekly["speed_score"] 

    fastest_time = weekly["fastest_time"]
    fastest_time = score[:fastest_time] if score[:fastest_time] < weekly["fastest_time"]

    slowest_time = weekly["slowest_time"]
    slowest_time = score[:slowest_time] if score[:slowest_time] > weekly["slowest_time"]

    data_points = weekly["data_points"]
    data_points += 1 

    {
      "speed_score" => speed_score,
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