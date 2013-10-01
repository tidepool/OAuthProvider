class EmoIntelligenceResult < Result
  store_accessor :score, :eq_score
  store_accessor :score, :corrects
  store_accessor :score, :incorrects
  store_accessor :score, :instant_replays
  store_accessor :score, :time_elapsed

  def active_model_serializer
    EmoIntelligenceResultSerializer
  end

  def self.create_from_analysis(game, analysis_results, existing_result = nil)
    return nil unless game && game.user_id
    return nil unless analysis_results && analysis_results[:emo_intelligence] && analysis_results[:emo_intelligence][:score]

    result = existing_result
    result = game.results.build(:type => 'EmoIntelligenceResult') if result.nil?

    result.user_id = game.user_id
    score = analysis_results[:emo_intelligence][:score]
    result.eq_score = score[:eq_score]
    result.corrects = score[:corrects]
    result.incorrects = score[:incorrects]
    result.instant_replays = score[:instant_replays]
    result.time_elapsed = score[:time_elapsed]

    result.analysis_version = score[:version]
    result.record_times(game, analysis_results[:emo_intelligence][:timezone_offset])
    result.save ? result : nil
  end

end