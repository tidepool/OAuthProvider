class PersistEmo 
  include CalculationUtils

  def persist(game, analysis_results)
    return if !game && !game.user_id

    # There is only one result instance if this type per game
    existing_result = Result.find_for_type(game, 'EmoResult')
    result = EmoResult.create_from_analysis(game, analysis_results, existing_result)
  end
end