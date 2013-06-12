class PersistProfile 
  def persist(game, results)
    return if !game && !game.user_id

    user = User.find(game.user_id)
    return if !user

    scores = results[:scores]
    return if !scores

    big5_dimension = (scores[:big5] && scores[:big5][:dimension]) ? scores[:big5][:dimension] : nil 
    holland6_dimension = (scores[:holland6] && scores[:holland6][:dimension] ? scores[:holland6][:dimension] : nil)

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
    # result.save!
  end
end