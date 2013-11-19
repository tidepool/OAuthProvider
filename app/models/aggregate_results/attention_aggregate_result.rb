class AttentionAggregateResult < AggregateResult
  include TimeZoneCalculations

  store_accessor :high_scores, :all_time_best
  store_accessor :high_scores, :daily_best
  store_accessor :high_scores, :daily_average
  store_accessor :high_scores, :daily_total
  store_accessor :high_scores, :daily_data_points
  store_accessor :high_scores, :current_day
  store_accessor :high_scores, :last_value

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

  def last_value=(value)
    super(value.to_i)
  end

  def last_value
    super.to_i
  end

  def self.create_from_analysis(game, analysis_results, time, existing_result = nil)
    return nil unless game && game.user_id
    return nil unless analysis_results && analysis_results[:attention] && analysis_results[:attention][:score]

    timezone_offset = analysis_results[:attention][:timezone_offset].to_i

    result = existing_result
    if result.nil?
      result = AggregateResult.create(type: 'AttentionAggregateResult', user_id: game.user_id)
      result.initialize_scores
      result.initialize_high_scores(result.time_from_offset(time, timezone_offset))
    end

    result.initialize_high_scores(result.time_from_offset(time, timezone_offset)) if result.high_scores.nil?
    score = analysis_results[:attention][:score]

    result.high_scores = result.update_high_scores(score[:attention_score].to_i, time, timezone_offset, game)

    # Update the circadian results
    hour = result.time_from_offset(time, timezone_offset).hour
    circadian = result.scores["circadian"]
    circadian[hour.to_s] = result.update_circadian(score[:attention_score], hour)

    # Update the weekly results
    day = result.time_from_offset(time, timezone_offset).wday
    weekly = result.scores["weekly"]
    trend = result.calculate_trend(score[:attention_score], weekly[day]['average_score'])
    weekly[day] = result.update_weekly(weekly[day], score[:attention_score], result.daily_average)

    result.scores = {
      "circadian" => circadian,
      "weekly" => weekly,
      "trend" => trend
    }
    result.last_value = score[:attention_score]
    result.save ? result : nil
  end

end