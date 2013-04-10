class PersistScores

  def persist(assessment, results)
    return if !assessment

    result = assessment.result.nil? ? assessment.create_result : assessment.result

    result.event_log = results[:event_log]
    result.intermediate_results = results[:intermediate_results]
    result.aggregate_results = results[:aggregate_results]
    result.scores = results[:scores]
    result.save
  end
end