class AuthenticationSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :provider, :uid, :oauth_token, :oauth_secret, :oauth_expires_at, :oauth_refresh_at, :permissions

end
