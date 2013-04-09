class PersistProfile 
  def persist(assessment, results)
    return if !assessment && !assessment.user_id

    user = User.find(assessment.user_id)
    return if !user

    result = assessment.result
    if !result
      result = Result.create(:assessment_id => assessment.id)
    end

    scores = results[:scores]
    return if !scores

    big5_dimension = (scores[:big5] && scores[:big5][:big5_dimension]) ? scores[:big5_dimension] : nil 
    holland6_dimension = (scores[:holland6] && scores[:holland6][:holland6_dimension] ? scores[:holland6_dimension] : nil)

    return if big5_dimension == nil || holland6_dimension == nil

    profile_description = ProfileDescription.where('big5_dimension = ? AND holland6_dimension = ?', big5_dimension, holland6_dimension).first

    user.profile_description = profile_description
    user.save

    result.profile_description = profile_description
    result.save
  end
end