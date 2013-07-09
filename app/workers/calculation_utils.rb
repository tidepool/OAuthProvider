module CalculationUtils
  def record_times(game, result)
    result.time_played = game.date_taken
    result.time_calculated = Time.zone.now
  end
end