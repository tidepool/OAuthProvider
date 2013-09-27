class SpeedArchetypeResult < Result
  store_accessor :score, :fastest_time
  store_accessor :score, :slowest_time
  store_accessor :score, :average_time
  store_accessor :score, :average_time_simple
  store_accessor :score, :average_time_complex
  store_accessor :score, :description_id
  store_accessor :score, :speed_score

  def active_model_serializer
    SpeedArchetypeResultSerializer
  end

  def self.create_from_analysis(game, analysis_results, description, version, existing_result = nil)
    return nil unless game && game.user_id
    return nil if description.nil?

    result = existing_result
    result = game.results.build(:type => 'SpeedArchetypeResult') if result.nil?
    result.user_id = game.user_id

    score = analysis_results[:reaction_time2][:score]
    result.fastest_time = score[:fastest_time]
    result.slowest_time = score[:slowest_time]
    result.average_time = score[:average_time]
    result.speed_score = score[:speed_score]
    result.average_time_simple = score[:average_time_simple]
    result.average_time_complex = score[:average_time_complex]

    result.description_id = description.id # This is an HStore accessor so needs to use id

    result.calculations = {
      "stage_data" => score[:stage_data]
    }
    result.analysis_version = version
    result.record_times(game, analysis_results[:reaction_time2][:timezone_offset])
    result.save ? result : nil
  end
end
