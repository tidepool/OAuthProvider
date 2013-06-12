class PersistScores

  def persist(game, results)
    return if !game

    result = game.result.nil? ? game.create_result : game.result

    result.event_log = results[:event_log]
    result.intermediate_results = results[:intermediate_results]
    result.aggregate_results = results[:aggregate_results]
    # result.scores = results[:scores]
    result.save!
  end
end