class PersonalityResultSerializer < ActiveModel::Serializer
  attributes :id, :game_id, :user_id, :type, :name, :one_liner, :logo_url, :time_played, :time_calculated

  def initialize(object, options={})
    super 
    find_profile_description
  end

  def name
    @desc.name if @desc
  end

  def one_liner
    @desc.one_liner if @desc
  end

  def logo_url
    @desc.logo_url if @desc
  end

  def find_profile_description
    desc_id = object.profile_description_id
    if desc_id
      @desc ||= Rails.cache.fetch("ProfileDescription_#{desc_id}", expires_in: 1.hours) do
        ProfileDescription.find(desc_id) 
      end   
    end
  end
end