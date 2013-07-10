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
    result.weakest_emotion = score[:weakest_emotion][:emotion]
    result.strongest_emotion = score[:strongest_emotion][:emotion]
    result.flagged_result1 = score[:flagged_result1]

    emo_name = result.strongest_emotion
    if result.flagged_result1 && result.flagged_result1.to_bool
      emo_name = "flagged_result1"
    end

    # TODO: This is a bit too denormalized to store the emotion
    # descriptions in the results. Reconsider this...
    emo_desc = EmotionDescription.where(name: emo_name).first

    result.display_emotion_name = emo_name
    result.display_emotion_friendly = emo_desc.friendly_name 
    result.display_emotion_title = emo_desc.title
    result.display_emotion_description = emo_desc.description

    result.calculations = {
      final_results: analysis_results[:emo][:final_results]
    }
    result.analysis_version = score[:version]
    record_times(game, result)
    result.save!
  end
end