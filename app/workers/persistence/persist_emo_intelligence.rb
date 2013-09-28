class PersistEmoIntelligence 
  def persist(game, analysis_results)
    # There is only one result instance if this type per game
    existing_result = Result.find_for_type(game, 'EmoIntelligenceResult')
    result = EmoIntelligenceResult.create_from_analysis(game, analysis_results, existing_result)

    raise Workers::PersistenceError, 'Emo result for game #{game.id} can not be persisted.' if result.nil?
  end
end