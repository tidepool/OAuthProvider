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
    result.reported_emotion = score[:reported_emotion]
    result.calculated_emotion = score[:calculated_emotion]

    # TODO: This is a bit too denormalized to store the emotion
    # descriptions in the results. Reconsider this...
    emo_desc = EmotionDescription.where(name: result.reported_emotion).first

    result.display_emotion_name = result.reported_emotion
    result.display_emotion_friendly = emo_desc.friendly_name 
    result.display_emotion_title = emo_desc.title
    result.display_emotion_description = emo_desc.description

    emo_distances = nil
    analysis_results[:emo][:final_results].each do |final_results|
      if final_results[:emo_distances]
        emo_distances = final_results[:emo_distances]
      end
    end

    result.calculations = {
      emo_distances: emo_distances,
      final_results: analysis_results[:emo][:final_results]
    }
    result.analysis_version = score[:version]
    record_times(game, result)
    result.save!
  end
end