class AttentionResult < Result
  store_accessor :score, :attention_score

  def active_model_serializer
    AttentionResultSerializer
  end

  def self.create_from_analysis(game, analysis_results, existing_result = nil)
    return nil unless game && game.user_id
    return nil unless analysis_results && analysis_results[:attention] && analysis_results[:attention][:score]

    result = existing_result
    result = game.results.build(:type => 'AttentionResult') if result.nil?

    result.user_id = game.user_id
    score = analysis_results[:attention][:score]
    result.attention_score = score[:attention_score]

    result.calculations = {
      stage_scores: score[:stage_scores]
    }

    result.analysis_version = score[:version]
    result.record_times(game, analysis_results[:attention][:timezone_offset])
    result.save ? result : nil
  end

end