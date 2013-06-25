class CareerRecommendationSerializer < ActiveModel::Serializer
  attributes :id, :profile_description_id, :careers, :tools, :skills

end