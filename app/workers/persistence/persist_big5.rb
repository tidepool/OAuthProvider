class PersistBig5 
  include CalculationUtils

  def persist(game, analysis_results)
    return if !game && !game.user_id
    return unless analysis_results && analysis_results[:big5] && analysis_results[:big5][:score]

    # There is only one result instance if this type per game
    result = Result.find_for_type(game, 'Big5Result')
    result = game.results.build(:type => 'Big5Result') if result.nil?

    result.user_id = game.user_id
    score = analysis_results[:big5][:score]
    result.dimension = score[:dimension]
    result.low_dimension = score[:low_dimension]
    result.high_dimension = score[:high_dimension]
    result.adjust_by = score[:adjust_by]
    result.calculations = {
      dimension_values: score[:dimension_values],
      final_results: analysis_results[:big5][:final_results]
    }
    result.analysis_version = score[:version]
    record_times(game, result)
    result.save!
  end
end