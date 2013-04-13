require 'pry' if Rails.env.test? || Rails.env.development?

class PersistProfile 
  def persist(assessment, results)
    return if !assessment && !assessment.user_id

    user = User.find(assessment.user_id)
    return if !user

    result = assessment.result.nil? ? assessment.create_result : assessment.result

    scores = results[:scores]
    return if !scores

    big5_dimension = (scores[:big5] && scores[:big5][:dimension]) ? scores[:big5][:dimension] : nil 
    holland6_dimension = (scores[:holland6] && scores[:holland6][:dimension] ? scores[:holland6][:dimension] : nil)

    return if big5_dimension == nil || holland6_dimension == nil

    profile_description = ProfileDescription.where('big5_dimension = ? AND holland6_dimension = ?', big5_dimension, holland6_dimension).first

    user.profile_description = profile_description
    user.save

    result.profile_description = profile_description
    result.save
  end
end