class ProfileDescriptionSerializer < ActiveModel::Serializer
  cached

  attributes :id, :name, :description, :one_liner, :bullet_description, :big5_dimension, :holland6_dimension, :code, :logo_url, :display_id 

  def cache_key
    [object]
  end
end