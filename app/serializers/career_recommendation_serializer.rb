class CareerRecommendationSerializer < ActiveModel::Serializer
  cached
  
  attributes :id, :profile_description_id, :careers, :tools, :skills

  def cache_key
    [object]
  end
end