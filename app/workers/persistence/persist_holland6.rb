class PersistHolland6 
  include CalculationUtils

  def persist(game, analysis_results)
    return if !game && !game.user_id
    return unless analysis_results && analysis_results[:holland6] && analysis_results[:holland6][:score]

    # There is only one result instance if this type per game
    result = Result.find_for_type(game, 'Holland6Result')
    result = game.results.build(:type => 'Holland6Result') if result.nil?

    result.user_id = game.user_id
    score = analysis_results[:holland6][:score]
    result.dimension = score[:dimension]
    result.adjust_by = score[:adjust_by]
    # result.score = {
    #   dimension: score[:dimension],
    #   adjust_by: score[:adjust_by]
    # }
    result.calculations = {
      dimension_values: score[:dimension_values],
      final_results: analysis_results[:holland6][:final_results]
    }
    result.analysis_version = score[:version]
    record_times(game, result)
    result.save!
  end
end