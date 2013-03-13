class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :gender

  has_one :profile_description
end
