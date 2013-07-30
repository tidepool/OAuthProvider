class PersistHolland6 
  def persist(game, analysis_results)
    # There is only one result instance if this type per game
    existing_result = Result.find_for_type(game, 'Holland6Result')
    result = Holland6Result.create_from_analysis(game, analysis_results, existing_result)

    raise Workers::PersistenceError, 'Holland6 result for game #{game.id} can not be persisted.' if result.nil?
  end
end