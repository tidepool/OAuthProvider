class PersistPersonality 
  include CalculationUtils

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

    personality.big5_score = big5_score[:dimension_values]
    personality.big5_dimension = big5_dimension
    personality.big5_low = big5_score[:low_dimension]    
    personality.big5_high = big5_score[:high_dimension]

    personality.holland6_score = holland6_score[:dimension_values]
    personality.holland6_dimension = holland6_dimension

    personality.save!
    user.save!

    # There is only one result instance if this type per game
    result = Result.find_for_type(game, 'PersonalityResult')
    result = game.results.build(:type => 'PersonalityResult') if result.nil?

    result.name = profile_description.name
    result.one_liner = profile_description.one_liner
    result.logo_url = profile_description.logo_url
    result.profile_description_id = profile_description.id # This is an HStore accessor so needs to use id
    # result.score = {
    #   "name" => profile_description.name,
    #   "one_liner" => profile_description.one_liner,
    #   "logo_url" => profile_description.logo_url,
    #   "profile_description_id" => profile_description.id
    # }
    result.calculations = {}
    result.analysis_version = big5_score[:version] # We pick one of big5 vs. holland6 for the version here
    record_times(game, result)
    result.save!
  end
end