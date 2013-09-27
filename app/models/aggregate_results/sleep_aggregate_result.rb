class SleepAggregateResult < AggregateResult
  def self.create_from_latest(sleep, user_id, date)
    result = SleepAggregateResult.where(user_id: user_id).first_or_initialize

    weekly = result.scores['weekly'] if result.scores
    weekly = result.initialize_weekly if weekly.nil?

    week_day = date ? date.wday : 0

    prior_most_minutes = weekly[week_day]['most_minutes'] ? weekly[week_day]['most_minutes'].to_i : 0
    prior_least_minutes = weekly[week_day]['least_minutes'] ? weekly[week_day]['least_minutes'].to_i : 1000000
    prior_total = weekly[week_day]['total'] ? weekly[week_day]['total'].to_i : 0
    prior_data_points = weekly[week_day]['data_points'] ? weekly[week_day]['data_points'].to_i : 0

    weekly[week_day] = {
      'most_minutes' => sleep.total_minutes_asleep.to_i > prior_most_minutes ? sleep.total_minutes_asleep.to_i : prior_most_minutes,
      'least_minutes' => sleep.total_minutes_asleep.to_i < prior_least_minutes ? sleep.total_minutes_asleep.to_i : prior_least_minutes,
      'total' => sleep.total_minutes_asleep.to_i + prior_total,
      'average' => (sleep.total_minutes_asleep.to_i + prior_total) / (prior_data_points + 1),
      'data_points' => prior_data_points + 1
    }

    trend = result.calculate_trend(sleep.total_minutes_asleep.to_f, weekly[week_day]['average'])

    result.scores = {
      'weekly' => weekly, 
      'trend' => trend,
      'last_updated' => date.to_s,
      'last_value' => sleep.total_minutes_asleep 
    }
    result.save ? result : nil
  end

  def initialize_weekly
    weekly = []
    (0..6).each do |i|
      weekly << {
        'most_minutes' => 0,
        'least_minutes' => 1000000,
        'total' => 0,
        'average' => 0,
        'data_points' => 0
      }
    end
    weekly
  end
end