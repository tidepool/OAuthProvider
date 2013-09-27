class ActivityAggregateResult < AggregateResult
  def self.create_from_latest(activity, user_id, date)
    result = ActivityAggregateResult.where(user_id: user_id).first_or_initialize

    weekly = result.scores['weekly'] if result.scores
    weekly = result.initialize_weekly if weekly.nil?

    week_day = date ? date.wday : 0
    # logger.info("AggregateResult: For day #{week_day}.")
    weekly[week_day], last_value, last_updated, trend = result.calculate_weekly_average(date, weekly[week_day], activity.steps.to_i)
    # logger.info("AggregateResult: start synchronize.")
    result.scores = {
      'weekly' => weekly,
      'trend' => trend,
      'last_updated' => last_updated.to_s,
      'last_value' => last_value 
    }
    result.save ? result : nil
  end

  def initialize_weekly
    weekly = []
    (0..6).each do |i|
      weekly << {
        'most_steps' => 0,
        'total' => 0,
        'average' => 0,
        'data_points' => 0
      }
    end
    weekly
  end

  def calculate_weekly_average(date, week_day_score, new_value)
    # We may be getting multiple activity updates for activities
    # We need to ignore the multiple ones we get for a given day
    # and get the last one only.

    if self.scores && self.scores['last_updated'] && self.scores['last_updated'].class == String
      # This logic is a bit too much, but had to have it for bad dataset in the databases
      last_updated_str = self.scores['last_updated']
    else
      last_updated_str = (Date.current - 5.days).to_s
    end
    last_updated = Date.parse(last_updated_str)
    last_value = self.scores && self.scores['last_value'] ? self.scores['last_value'].to_i : 0
    total = week_day_score['total'] ? week_day_score['total'].to_i : 0
    data_points = week_day_score['data_points'] ? week_day_score['data_points'].to_i : 0

    if date.yday == last_updated.yday
      # This means we have new data for the day, so update the averages accordingly.
      total = total - last_value + new_value.to_i
      data_points = data_points - 1 + 1
    else
      total = total + new_value.to_i
      data_points += 1
    end    

    average = total.to_f / data_points.to_f
    prior_most_steps = week_day_score['most_steps'] ? week_day_score['most_steps'].to_i : 0
    most_steps = new_value > prior_most_steps ? new_value : prior_most_steps
    
    trend = calculate_trend(new_value.to_f, average.to_f)
    return {
      'most_steps' => most_steps,
      'total' => total,
      'average' => average,
      'data_points' => data_points
    }, new_value, date, trend
  end

end