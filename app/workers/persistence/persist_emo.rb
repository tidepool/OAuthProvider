class PersistEmo 
  include CalculationUtils

  def persist(game, analysis_results)
    return if !game && !game.user_id
    return unless analysis_results && analysis_results[:emo] && analysis_results[:emo][:score]

    # There is only one result instance if this type per game
    result = Result.find_for_type(game, 'EmoResult')
    result = game.results.build(:type => 'EmoResult') if result.nil?

    result.user_id = game.user_id
    score = analysis_results[:emo][:score]
    result.factor1 = score[:factors][:factor1]
    result.factor2 = score[:factors][:factor2]
    result.factor3 = score[:factors][:factor3]
    result.factor4 = score[:factors][:factor4]
    result.factor5 = score[:factors][:factor5]
    result.furthest_emotion = score[:furthest_emotion][:emotion]
    result.closest_emotion = score[:closest_emotion][:emotion]

    result.calculations = {
      final_results: analysis_results[:emo][:final_results]
    }
    result.analysis_version = score[:version]
    record_times(game, result)
    result.save!
  end
end