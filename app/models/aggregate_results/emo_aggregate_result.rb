class EmoAggregateResult < AggregateResult
  include TimeZoneCalculations

  store_accessor :high_scores, :all_time_best
  store_accessor :high_scores, :daily_best
  store_accessor :high_scores, :daily_average
  store_accessor :high_scores, :daily_total
  store_accessor :high_scores, :daily_data_points
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

  def self.create_from_analysis(game, analysis_results, time, existing_result = nil)
    return nil unless game && game.user_id
    return nil unless analysis_results && analysis_results[:emo_intelligence] && analysis_results[:emo_intelligence][:score]

    timezone_offset = analysis_results[:emo_intelligence][:timezone_offset].to_i

    result = existing_result
    if result.nil?
     result = AggregateResult.create(type: 'EmoAggregateResult', user_id: game.user_id)
     result.initialize_high_scores(result.time_from_offset(time, timezone_offset))
    end

    result.initialize_high_scores(result.time_from_offset(time, timezone_offset)) if result.high_scores.nil?
 
    score = analysis_results[:emo_intelligence][:score]
    # Update the high scores
    result.high_scores = result.update_high_scores(score[:eq_score].to_i, time, timezone_offset)

    result.save ? result : nil
  end
end