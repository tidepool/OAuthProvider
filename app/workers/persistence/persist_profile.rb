class PersistProfile 
  def persist(game, analysis_results)
    return if !game && !game.user_id

    user = User.find(game.user_id)
    return if !user

    # scores = analysis_results[:scores]
    # return if !scores
    return unless analysis_results && analysis_results[:big5] && analysis_results[:big5][:score]
    return unless analysis_results && analysis_results[:holland6] && analysis_results[:holland6][:score]

    big5_score = analysis_results[:big5][:score]
    holland6_score = analysis_results[:holland6][:score]

    big5_dimension = big5_score[:dimension] ? big5_score[:dimension] : nil 
    holland6_dimension = holland6_score[:dimension] ? holland6_score[:dimension] : nil

    return if big5_dimension == nil || holland6_dimension == nil

    profile_description = ProfileDescription.where('big5_dimension = ? AND holland6_dimension = ?', big5_dimension, holland6_dimension).first

    personality = user.create_personality
    personality.profile_description = profile_description
    personality.game = game

    personality.big5_score = scores[:big5][:score]
    personality.big5_dimension = scores[:big5][:dimension]
    personality.big5_low = scores[:big5][:low_dimension]    
    personality.big5_high = scores[:big5][:high_dimension]

    personality.holland6_score = scores[:holland6][:score]
    personality.holland6_dimension = scores[:holland6][:dimension]

    personality.save!
    user.save!(:validate => false)
  end
end