class PersistReactionTime 
  include CalculationUtils

  def persist(game, analysis_results)
    return if !game && !game.user_id
    return unless analysis_results && analysis_results[:reaction_time] && analysis_results[:reaction_time][:score]

    user = User.find(game.user_id)
    return if !user

    # There is only one result instance if this type per game
    result = Result.find_for_type(game, 'ReactionTimeResult')
    result = game.results.build if result.nil?

    result.user = user
    result.type = "ReactionTimeResult"
    score = analysis_results[:reaction_time][:score]
    result.score = {
      "fastest_time" => score[:fastest_time],
      "slowest_time" => score[:slowest_time],
      "average_time" => score[:average_time]
    }
    result.calculations = {
      "final_results" => analysis_results[:reaction_time][:final_results]
    }
    result.analysis_version = score[:version]
    record_times(game, result)
    result.save!

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