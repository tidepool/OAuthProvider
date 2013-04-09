class PersistScores

  def persist(assessment, results)
    return if !assessment

    result = assessment.result
    if !result
      result = Result.create(:assessment_id => assessment.id)
    end

    result.event_log = results[:event_log]
    result.intermediate_results = results[:intermediate_results]
    result.aggregate_results = results[:aggregate_results]
    result.scores = results[:scores]
    result.save
  end
end