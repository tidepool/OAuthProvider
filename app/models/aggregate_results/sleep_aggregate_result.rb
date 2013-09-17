class SleepAggregateResult < AggregateResult
  def self.create_from_latest(sleep, user_id, date)

    result = SleepAggregateResult.where(user_id: user_id).first_or_initialize

    weekly = result.scores['weekly'] if result.scores
    weekly = result.initialize_weekly if weekly.nil?

    week_day = date && date.class == Date ? date.wday : 0
    weekly[week_day] = {
      'most_minutes' => sleep.total_minutes_asleep > weekly[week_day]['most_minutes'] ? sleep.total_minutes_asleep : weekly[week_day]['most_minutes'],
      'least_minutes' => sleep.total_minutes_asleep < weekly[week_day]['least_minutes'] ? sleep.total_minutes_asleep : weekly[week_day]['least_minutes'],
      'total_minutes' => sleep.total_minutes_asleep + weekly[week_day]['total_minutes'],
      'average_minutes' => (sleep.total_minutes_asleep + weekly[week_day]['total_minutes']) / (weekly[week_day]['data_points'] + 1),
      'data_points' => weekly[week_day]['data_points'] + 1
    }

    result.scores = {
      'weekly' => weekly
    }
    result.save ? result : nil
  end

  def initialize_weekly
    weekly = []
    (0..6).each do |i|
      weekly << {
        'most_minutes' => 0,
        'least_minutes' => 1000000,
        'total_minutes' => 0,
        'average_minutes' => 0,
        'data_points' => 0
      }
    end
    weekly
  end
end