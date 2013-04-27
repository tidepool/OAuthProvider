class AuthenticationSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :provider

end
