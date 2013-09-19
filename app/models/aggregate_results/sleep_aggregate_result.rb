class SleepAggregateResult < AggregateResult
  def self.create_from_latest(sleep, user_id, date)
    result = SleepAggregateResult.where(user_id: user_id).first_or_initialize

    weekly = result.scores['weekly'] if result.scores
    weekly = result.initialize_weekly if weekly.nil?

    week_day = date && date.class == Date ? date.wday : 0
    weekly[week_day] = {
      'most_minutes' => sleep.total_minutes_asleep.to_i > weekly[week_day]['most_minutes'].to_i ? sleep.total_minutes_asleep.to_i : weekly[week_day]['most_minutes'].to_i,
      'least_minutes' => sleep.total_minutes_asleep.to_i < weekly[week_day]['least_minutes'].to_i ? sleep.total_minutes_asleep.to_i : weekly[week_day]['least_minutes'].to_i,
      'total' => sleep.total_minutes_asleep.to_i + weekly[week_day]['total'].to_i,
      'average' => (sleep.total_minutes_asleep.to_i + weekly[week_day]['total']).to_i / (weekly[week_day]['data_points'].to_i + 1),
      'data_points' => weekly[week_day]['data_points'].to_i + 1
    }

    trend, new_sleep_minutes, last_updated = result.calculate_trend(date, sleep.total_minutes_asleep)

    result.scores = {
      'weekly' => weekly, 
      'trend' => trend,
      'last_value' => new_sleep_minutes,
      'last_updated' => last_updated.to_s
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