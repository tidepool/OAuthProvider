class PersistSurvey 
  include CalculationUtils

  def persist(game, analysis_results)
    return if !game && !game.user_id
    return unless analysis_results && analysis_results[:survey] && analysis_results[:survey][:score]

    # There is only one result instance if this type per game
    result = Result.find_for_type(game, 'SurveyResult')
    result = game.results.build(:type => 'SurveyResult') if result.nil?

    result.user_id = game.user_id

    survey_score = analysis_results[:survey][:score]

    survey_results = {}
    survey_score.each do | topic, value |
      if topic.to_sym != :version
        survey_results[topic] = value[:answer]
      end
    end

    result.score = survey_results
    result.calculations = survey_score 

    result.analysis_version = survey_score[:version]
    record_times(game, result)
    result.save!
  end
end