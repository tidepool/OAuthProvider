class PersonalitySerializer < ActiveModel::Serializer
  attributes :id, :big5_dimension, :holland6_dimension, :big5_score, :holland6_score, :big5_low, :big5_high, :profile_description 

  # has_one :profile_description
  def profile_description
    desc = nil
    desc_id = object.profile_description_id   
    if desc_id 
      desc ||= Rails.cache.fetch("ProfileDescription_#{desc_id}", expires_in: 1.hours) do
        ProfileDescription.find(desc_id) 
      end
    end 
    desc
  end
end