class PersistSpeedArchetype 
  def persist(game, analysis_results)
    unless analysis_results && analysis_results[:reaction_time2] && analysis_results[:reaction_time2][:score]
      raise Workers::PersistenceError, "Analysis does not contain ReactionTime2 scores."
    end

    # Below will raise exception if not found ActiveRecord::NotFound
    user = User.find(game.user_id)

    reaction_time2_score = analysis_results[:reaction_time2][:score]

    speed_archetype = reaction_time2_score[:speed_archetype] ? reaction_time2_score[:speed_archetype] : nil  
    if speed_archetype == nil
      raise Workers::PersistenceError, "Speed archetype cannot be found."
    end
    personality = user.personality
    big5_dimension = ""
    if personality == nil
      # raise Workers::PersistenceError, "User personality is not yet calculated."
      big5_dimension = "high_extraversion"
    else
      big5_dimension = personality.big5_dimension
    end

    reaction_time_description = ReactionTimeDescription.where('speed_archetype = ? AND big5_dimension = ?', speed_archetype, big5_dimension).first

    raise Workers::PersistenceError, "Reaction time description cannot be found for #{speed_archetype} and #{big5_dimension}." if reaction_time_description.nil?

    # There is only one result instance if this type per game
    existing_result = Result.find_for_type(game, 'SpeedArchetypeResult')
    version = reaction_time2_score[:version] # We pick one of big5 vs. holland6 for the version here
    result = SpeedArchetypeResult.create_from_analysis(game, analysis_results, reaction_time_description, version, existing_result)

    raise Workers::PersistenceError, 'SpeedArchetype result for game #{game.id} can not be persisted.' if result.nil?
  end
end