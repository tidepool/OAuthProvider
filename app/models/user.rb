class User < ActiveRecord::Base
  has_secure_password
  
  Dir[File.expand_path('../auth_providers/*.rb', __FILE__)].each do |file|
    require file 
    module_name = File.basename(file, '.rb').camelize 
    include Object.const_get(module_name)
  end

  attr_accessible :email, :password, :password_confirmation, :name, :display_name,
                  :description, :city, :state, :country, :timezone, :gender,
                  :date_of_birth, :locale
  validates_uniqueness_of :email

  belongs_to :profile_description
  has_many :authentications

  def set_if_empty(property, value, authentication)
    authentication[property] = value
    puts("Property: #{property}, Value: #{value}")
    if self[property].nil? || self[property].empty?
      self[property] = value
    end
  end

  def populate_from_auth_hash!(auth_hash)
    provider = auth_hash.provider
    # binding.remote_pry

    authentication = Authentication.find_by_provider_and_uid(auth_hash.provider, auth_hash.uid)
    if authentication 
      # An authentication already exists for the user, just attach it
      authentication.user_id = self.id
    else
      # Create a new authentication
      authentication = self.authentications.build(:provider => provider, :uid => auth_hash.uid)
    end 
    authentication.oauth_token = auth_hash.credentials.token
    if auth_hash.credentials.expires_at
      authentication.oauth_expires_at = Time.at(auth_hash.credentials.expires_at)
    end

    method_name = "populate_from_#{provider.underscore}"
    self.method(method_name.to_sym).call(auth_hash, authentication)
    authentication.save!
    self.save!(:validate => false)
  end
end
