class PersistHolland6 
  include CalculationUtils

  def persist(game, analysis_results)
    return if !game && !game.user_id
    return unless analysis_results && analysis_results[:holland6] && analysis_results[:holland6][:score]

    # There is only one result instance if this type per game
    result = Result.find_for_type(game, 'big5')
    result = game.results.build if result.nil?

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
    record_times(game, result)
    result.save!
  end
end