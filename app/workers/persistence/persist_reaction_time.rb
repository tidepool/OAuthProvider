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
     fastest_time: score[:fastest_time]
     slowest_time: score[:slowest_time]
     average_time: score[:average_time]
   }
   result.calculations = {
     final_results: analysis_results[:reaction_time][:final_results]
   }
   result.save!

   fastest_time = user.stats[:fastest_time]
   slowest_time = user.stats[:slowest_time]
   
  end
end