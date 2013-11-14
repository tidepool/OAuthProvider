class PublicProfileSerializer < ActiveModel::Serializer
  attributes :id, :name, :image, :personality

  def name
    if object.name.nil? || object.name.empty?
      object.email.split('@')[0]
    else
      object.name
    end
  end

  def personality
    personality = object.personality
    if personality.nil?
      {
        profile_description: {}
      }
    else
      desc = nil
      desc_id = object.profile_description_id   
      if desc_id 
        desc ||= Rails.cache.fetch("ProfileDescription_#{desc_id}", expires_in: 1.hours) do
          ProfileDescription.find(desc_id) 
        end
      end 
      {
        profile_description: desc
      }
    end
  end
end