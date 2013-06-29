class PersistHolland6 
  def persist(game, analysis_results)
    return if !game && !game.user_id
    return unless analysis_results && analysis_results[:holland6] && analysis_results[:holland6][:score]

    result = game.results.build
    result.user_id = game.user_id
    result.result_type = :holland6
    score = analysis_results[:holland6][:score]
    result.score = {
      dimension: score[:dimension],
      adjust_by: score[:adjust_by]
    }
    result.calculations = {
      dimension_values: score[:dimension_values],
      final_results: analysis_results[:holland6][:final_results]
    }
    result.save!
    
  end
end