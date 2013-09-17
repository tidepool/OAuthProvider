class ActivityAggregateResult < AggregateResult
  def self.create_from_latest(activity, user_id, date)

    result = ActivityAggregateResult.where(user_id: user_id).first_or_initialize

    weekly = result.scores['weekly'] if result.scores
    weekly = result.initialize_weekly if weekly.nil?

    week_day = date && date.class == Date ? date.wday : 0
    weekly[week_day] = {
      'most_steps' => activity.steps > weekly[week_day]['most_steps'] ? activity.steps : weekly[week_day]['most_steps'],
      'least_steps' => activity.steps < weekly[week_day]['least_steps'] ? activity.steps : weekly[week_day]['least_steps'],
      'total_steps' => activity.steps + weekly[week_day]['total_steps'],
      'average_steps' => (activity.steps + weekly[week_day]['total_steps']) / (weekly[week_day]['data_points'] + 1),
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
        'most_steps' => 0,
        'least_steps' => 1000000,
        'total_steps' => 0,
        'average_steps' => 0,
        'data_points' => 0
      }
    end
    weekly
  end
end