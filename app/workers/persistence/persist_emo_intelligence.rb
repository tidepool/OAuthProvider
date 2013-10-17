class PersistEmoIntelligence 
  def persist(game, analysis_results)
    aggregate_result = update_aggregate_result(game, analysis_results)

    # There is only one result instance if this type per game
    existing_result = Result.find_for_type(game, 'EmoIntelligenceResult')
    result = EmoIntelligenceResult.create_from_analysis(game, analysis_results, existing_result)

    raise Workers::PersistenceError, 'Emo result for game #{game.id} can not be persisted.' if result.nil?
  end

  def update_aggregate_result(game, analysis_results)
    existing_result = AggregateResult.find_for_type(game.user_id, 'EmoAggregateResult')
    time = Time.zone.now
    aggregate_result = EmoAggregateResult.create_from_analysis(game, analysis_results, time, existing_result)
    
    raise Workers::PersistenceError, "Cannot create the EmoAggregateResult." if aggregate_result.nil?

    aggregate_result
  end

end