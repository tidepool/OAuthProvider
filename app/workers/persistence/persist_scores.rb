class PersistScores

  def persist(game, result, analysis_results)
    return if !game

    # result = game.result.nil? ? game.create_result : game.result
    result.event_log = analysis_results[:event_log]
    result.intermediate_results = analysis_results[:intermediate_results]
    result.aggregate_results = analysis_results[:aggregate_results]
    result.save!
  end
end