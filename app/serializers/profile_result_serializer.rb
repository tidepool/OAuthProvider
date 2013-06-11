class ProfileResultSerializer < ActiveModel::Serializer
  attributes :id, :scores

  has_one :profile_description
end