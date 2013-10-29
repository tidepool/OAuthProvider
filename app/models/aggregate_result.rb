class AggregateResult < ActiveRecord::Base
  serialize :scores, JSON
  belongs_to :user

  def self.find_for_type(user_id, result_type)
    result = AggregateResult.where('user_id = ? and type = ?', user_id, result_type).first
  end  

  def calculate_trend(new_value, average)
    return 1.0 if average.nil? || average.to_f == 0.0 # If no average, yet, you will be 100%
    trend = (new_value.to_f - average.to_f) / average.to_f
  end

  def initialize_high_scores(time) 
    self.high_scores = {
      "all_time_best" => 0,
      "daily_best" => 0,
      "daily_average" => 0.0,
      "daily_data_points" => 0,
      "daily_total" => 0,
      "last_score" => 0,
      "current_day" => time.to_s
    }
  end
  
  def update_high_scores(score, time, timezone_offset, game)
    all_time_best = update_all_time_best(score, game)
    today = time_from_offset(time, timezone_offset) 
    daily_best = update_daily_best(score, today, timezone_offset)
    daily_average, daily_total, daily_data_points = update_daily_average(score, today, timezone_offset)

    {
      all_time_best: all_time_best,
      daily_best: daily_best,
      daily_average: daily_average,
      daily_data_points: daily_data_points,
      daily_total: daily_total,
      last_score: score,
      current_day: today.to_s
    }
  end

  def update_all_time_best(score, game)
    best_score = self.all_time_best
    if best_score.nil? || score > best_score
      best_score = score 
    end
    
    if game
      lb_service = LeaderboardService.new(game.name, self.user_id)
      lb_service.update_global_leaderboard(best_score)
    end
    best_score
  end

  def update_daily_best(score, day, timezone_offset)
    stored_year_day = time_from_offset(Time.zone.parse(self.high_scores[:current_day]), timezone_offset).yday
    year_day = day.yday

    best_score = score
    if stored_year_day == year_day
      best_score = self.daily_best
      best_score = score if best_score.nil? || score > best_score
    end
    best_score
  end

  def update_daily_average(score, day, timezone_offset)
    stored_year_day = time_from_offset(Time.zone.parse(self.high_scores[:current_day]), timezone_offset).yday
    year_day = day.yday

    prev_total = 0 
    prev_data_points = 0
    if stored_year_day == year_day
      prev_total = self.daily_total.to_i
      prev_data_points = self.daily_data_points.to_i
    end

    daily_total = prev_total + score.to_i 
    daily_data_points = prev_data_points + 1
    daily_average = daily_total / daily_data_points

    return daily_average, daily_total, daily_data_points
  end
end
