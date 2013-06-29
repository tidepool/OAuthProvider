class PersistReactionTime 
  def persist(game, analysis_results)
    return if !game && !game.user_id
    return unless analysis_results && analysis_results[:reaction_time] && analysis_results[:reaction_time][:score]

    user = User.find(game.user_id)
    return if !user

    result = game.results.build
    result.user = user
    result.result_type = :reaction_time
    score = analysis_results[:reaction_time][:score]
    result.score = {
      "fastest_time" => score[:fastest_time],
      "slowest_time" => score[:slowest_time],
      "average_time" => score[:average_time]
    }
    result.calculations = {
      final_results: analysis_results[:reaction_time][:final_results]
    }
    result.save!

    # Update the User stats by the new fastest and slowest time if they are fastest and slowest
    fastest_time = user.stats ? user.stats["fastest_time"].to_i : nil
    slowest_time = user.stats ? user.stats["slowest_time"].to_i : nil

    user.stats ||= {}  
    user.stats["fastest_time"] = result.score["fastest_time"].to_s unless fastest_time && fastest_time < result.score["fastest_time"].to_i
    user.stats["slowest_time"] = result.score["slowest_time"].to_s unless slowest_time && slowest_time > result.score["slowest_time"].to_i

    foo = user.save!
    foo
  end
end