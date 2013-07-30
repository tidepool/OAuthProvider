class PersistSurvey 
  def persist(game, analysis_results)
    # There is only one result instance if this type per game
    existing_result = Result.find_for_type(game, 'SurveyResult')
    result = SurveyResult.create_from_analysis(game, analysis_results, existing_result)

    raise Workers::PersistenceError, 'Survey result for game #{game.id} can not be persisted.' if result.nil?
  end
end