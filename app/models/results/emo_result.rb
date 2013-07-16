class EmoResult < Result
  store_accessor :score, :factor1
  store_accessor :score, :factor2
  store_accessor :score, :factor3
  store_accessor :score, :factor4
  store_accessor :score, :factor5
  store_accessor :score, :strongest_emotion
  store_accessor :score, :weakest_emotion
  store_accessor :score, :reported_emotion
  store_accessor :score, :calculated_emotion

  store_accessor :score, :display_emotion_name
  store_accessor :score, :display_emotion_friendly
  store_accessor :score, :display_emotion_title
  store_accessor :score, :display_emotion_description

  def self.create_from_analysis(game, analysis_results, existing_result = nil)
    return nil unless analysis_results && analysis_results[:emo] && analysis_results[:emo][:score] && analysis_results[:emo][:final_results]

    # First gather and check all the results before creating it.
    # build seems to be writing to database before the save, when the 
    # column type is hstore (PostGres). 
    score = analysis_results[:emo][:score]
    factor1 = score[:factors][:factor1]
    factor2 = score[:factors][:factor2]
    factor3 = score[:factors][:factor3]
    factor4 = score[:factors][:factor4]
    factor5 = score[:factors][:factor5]
    weakest_emotion = score[:weakest_emotion]
    strongest_emotion = score[:strongest_emotion]
    reported_emotion = score[:reported_emotion]
    calculated_emotion = score[:calculated_emotion]
    emo_desc = EmotionDescription.where(name: reported_emotion).first

    emo_distances = nil
    analysis_results[:emo][:final_results].each do |final_results|
      emo_distances = final_results[:emo_distances] if final_results[:emo_distances]
    end

    return nil unless emo_desc && weakest_emotion && strongest_emotion && reported_emotion

    # Now build the result
    result = existing_result
    result = game.results.build(:type => 'EmoResult') if result.nil?
    result.user_id = game.user_id
    result.factor1 = factor1
    result.factor2 = factor2
    result.factor3 = factor3
    result.factor4 = factor4
    result.factor5 = factor5
    result.weakest_emotion = weakest_emotion[:emotion]
    result.strongest_emotion = strongest_emotion[:emotion]
    result.reported_emotion = reported_emotion
    result.calculated_emotion = calculated_emotion

    # TODO: This is a bit too denormalized to store the emotion
    # descriptions in the results. Reconsider this...

    result.display_emotion_name = reported_emotion
    result.display_emotion_friendly = emo_desc.friendly_name 
    result.display_emotion_title = emo_desc.title
    result.display_emotion_description = emo_desc.description

    result.calculations = {
      emo_distances: emo_distances,
      final_results: analysis_results[:emo][:final_results]
    }
    result.analysis_version = score[:version]
    result.record_times(game)
    result.save ? result : nil
  end
end
