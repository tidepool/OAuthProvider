class PersistPersonality 
  def persist(game, analysis_results)

    unless analysis_results && analysis_results[:big5] && analysis_results[:big5][:score]
      raise Workers::PersistenceError, "Analysis does not contain Big5 scores."
    end

    unless analysis_results && analysis_results[:holland6] && analysis_results[:holland6][:score]
      raise Workers::PersistenceError, "Analysis does not contain Holland6 scores."
    end

    big5_score = analysis_results[:big5][:score]
    holland6_score = analysis_results[:holland6][:score]

    big5_dimension = big5_score[:dimension] ? big5_score[:dimension] : nil 
    holland6_dimension = holland6_score[:dimension] ? holland6_score[:dimension] : nil

    if big5_dimension == nil || holland6_dimension == nil
      raise Workers::PersistenceError, "Big5 or Holland6 dimension score cannot be found."
    end

    profile_description = Rails.cache.fetch("ProfileDescription_#{big5_dimension}_#{holland6_dimension}", expires_in: 1.hours) do
      # ProfileDescription.find(desc_id) 
      ProfileDescription.where('big5_dimension = ? AND holland6_dimension = ?', big5_dimension, holland6_dimension).first
    end   

    raise Workers::PersistenceError, "Profile description cannot be found for #{big5_dimension} and #{holland6_dimension}." if profile_description.nil?

    # Below will raise exception if not found ActiveRecord::NotFound
    user = User.find(game.user_id)

    personality = user.personality # Override existing personality if it exists
    personality = user.create_personality if personality.nil?
    personality.profile_description = profile_description
    personality.game = game

    personality.big5_score = big5_score[:dimension_values]
    personality.big5_dimension = big5_dimension
    personality.big5_low = big5_score[:low_dimension]    
    personality.big5_high = big5_score[:high_dimension]

    personality.holland6_score = holland6_score[:dimension_values]
    personality.holland6_dimension = holland6_dimension

    personality.save!  # We would like this to raise exception if it fails
    user.save!         # We would like this to raise exception if it fails

    # There is only one result instance if this type per game
    existing_result = Result.find_for_type(game, 'PersonalityResult')
    return if existing_result

    version = big5_score[:version] # We pick one of big5 vs. holland6 for the version here
    result = PersonalityResult.create_from_analysis(game, profile_description, version, existing_result)

    raise Workers::PersistenceError, 'Personality result for game #{game.id} can not be persisted.' if result.nil?
  end
end