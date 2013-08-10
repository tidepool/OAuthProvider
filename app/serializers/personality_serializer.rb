class PersonalitySerializer < ActiveModel::Serializer
  cached
  attributes :id, :big5_dimension, :holland6_dimension, :big5_score, :holland6_score, :big5_low, :big5_high 

  has_one :profile_description

  def cache_key 
    [object, current_resource]
  end
end