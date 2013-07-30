class PersistReactionTime 
  def persist(game, analysis_results)
    # There is only one result instance if this type per game
    existing_result = Result.find_for_type(game, 'ReactionTimeResult')
    result = ReactionTimeResult.create_from_analysis(game, analysis_results, existing_result)

    raise Workers::PersistenceError, 'ReactionTime result for game #{game.id} can not be persisted.' if result.nil?

    user = User.find(game.user_id)

    unless analysis_results && analysis_results[:reaction_time] && analysis_results[:reaction_time][:score]
      raise Workers::PersistenceError, "Analysis does not contain ReactionTime scores."
    end

    score = analysis_results[:reaction_time][:score] 

    # Update the User stats by the new fastest and slowest time if they are fastest and slowest
    new_fastest_time = fastest_time = user.stats ? user.stats["fastest_time"].to_i : nil
    new_slowest_time = slowest_time = user.stats ? user.stats["slowest_time"].to_i : nil
    new_fastest_time = score[:fastest_time] unless fastest_time && fastest_time < score[:fastest_time]
    new_slowest_time = score[:slowest_time] unless slowest_time && slowest_time > score[:slowest_time]

    user.stats = {
      "fastest_time" => new_fastest_time,
      "slowest_time" => new_slowest_time
    }
    user.save!
  end
end