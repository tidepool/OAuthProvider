class ActivityAggregateResult < AggregateResult
  def self.create_from_latest(activity, user_id, date)
    result = ActivityAggregateResult.where(user_id: user_id).first_or_initialize

    weekly = result.scores['weekly'] if result.scores
    weekly = result.initialize_weekly if weekly.nil?

    week_day = date && date.class == Date ? date.wday : 0
    weekly[week_day] = {
      'most_steps' => activity.steps.to_i > weekly[week_day]['most_steps'].to_i ? activity.steps.to_i : weekly[week_day]['most_steps'].to_i,
      'least_steps' => activity.steps.to_i < weekly[week_day]['least_steps'].to_i ? activity.steps.to_i : weekly[week_day]['least_steps'].to_i,
      'total' => activity.steps.to_i + weekly[week_day]['total'].to_i,
      'average' => (activity.steps.to_i + weekly[week_day]['total'].to_i) / (weekly[week_day]['data_points'].to_i + 1),
      'data_points' => weekly[week_day]['data_points'].to_i + 1
    }

    trend, new_steps, last_updated = result.calculate_trend(date, activity.steps)

    result.scores = {
      'weekly' => weekly,
      'trend' => trend,
      'last_value' => new_steps,
      'last_updated' => last_updated.to_s
    }
    result.save ? result : nil
  end

  def initialize_weekly
    weekly = []
    (0..6).each do |i|
      weekly << {
        'most_steps' => 0,
        'least_steps' => 1000000,
        'total' => 0,
        'average' => 0,
        'data_points' => 0
      }
    end
    weekly
  end
end