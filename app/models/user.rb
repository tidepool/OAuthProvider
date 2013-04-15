class User < ActiveRecord::Base
  has_secure_password
  Dir[File.expand_path('../auth_providers/*.rb', __FILE__)].each do |file|
    require file 
    module_name = File.basename(file, '.rb').camelize 
    include Object.const_get(module_name)
  end

  attr_accessible :email, :password, :password_confirmation
  validates_uniqueness_of :email

  belongs_to :profile_description
  has_many :authentications

  def set_if_empty(property, value, authentication)
    authentication[property] = value
    if self[property].nil?
      self[property] = value
    end
  end

  def populate_from_auth_hash!(auth_hash)
    provider = auth_hash['provider']
    authentication = self.authentications.build(:provider => provider, :uid => auth_hash['uid'])
    authentication.oauth_token = auth.credentials.token
    authentication.oauth_expires_at = Time.at(auth.credentials.expires_at)

    method_name = "populate_from_#{provider.underscore}"
    self.method(method_name.to_sym).call(auth_hash, authentication)
    self.save!
  end
end
