class User < ActiveRecord::Base
  has_secure_password validations: false
  
  Dir[File.expand_path('../auth_providers/*.rb', __FILE__)].each do |file|
    require file 
    module_name = File.basename(file, '.rb').camelize 
    include Object.const_get(module_name)
  end

  validates_uniqueness_of :email
  validates_format_of :email, :with => /.+@.+\..+/i
  validates :password, :length => { :minimum => 8 }, :if => :needs_password?, on: :create
  validates_confirmation_of :password
  
  has_one :personality
  # belongs_to :profile_description
  has_many :authentications
  has_many :preorders

  def self.create_guest_or_registered(attributes)
    begin
      User.create_guest_or_registered!(attributes)
    rescue Exception => e
      # TODO: needs logging...
      nil
    end
  end

  def self.create_guest_or_registered!(attributes)
    user = User.new(attributes)
    if user.guest
      user.email = "guest_#{Time.now.to_i}#{rand(99)}@example.com"
      user.password = user.password_confirmation = "12345678"
      user.password_digest = "Tidepool-Guest-User"
    end
    user.save!
    user
  end

  def self.create_or_find(auth_hash, user_id = nil)
    begin
      User.create_or_find!(auth_hash, user_id)
    rescue Exception => e
      # TODO: needs logging...
      nil
    end
  end

  def self.create_or_find!(auth_hash, user_id = nil)
    user = nil

    # First check if the authentication already exists:
    authentication = Authentication.find_by_provider_and_uid(auth_hash.provider, auth_hash.uid)
    if authentication
      user = authentication.user
      if user.guest
        # Ensure that user is not guest
        user.guest = false
        user.save
      end
    else
      if user_id      
        # We are trying to add the new authentication by provider to the user (The user can be a guest)
        user = User.where('id = ?', user_id).first
        if user 
          user.populate_from_auth_hash!(auth_hash)
        end
      else
        # The user does not exist (even no guest existed that needs mutation)
        user = User.new
        user.populate_from_auth_hash!(auth_hash) if user
      end  
    end
    user
  end

  def needs_password?
    guest == false
  end

  def set_if_empty(property, value, authentication)
    authentication[property] = value
    if self[property].nil? || self[property].empty? || self.guest
      self[property] = value
    end
  end

  def update_attributes(attributes)
    begin
      self.update_attributes!(attributes)
    rescue Exception => e
      false
    end
  end

  def update_attributes!(attributes)
    self.guest = false # The user is no longer a guest
    super
  end

  def populate_from_auth_hash!(auth_hash)
    provider = auth_hash.provider

    authentication = self.authentications.build(:provider => provider, :uid => auth_hash.uid)
    authentication.oauth_token = auth_hash.credentials.token
    if auth_hash.credentials.expires_at
      authentication.oauth_expires_at = Time.at(auth_hash.credentials.expires_at)
    end

    method_name = "populate_from_#{provider.underscore}".to_sym
    if self.method(method_name)
      self.method(method_name).call(auth_hash, authentication)
    end
    authentication.save!
    # As suggested here: (to prevent the password validation failing)
    # http://stackoverflow.com/questions/11917340/how-can-i-sometimes-require-password-and-sometimes-not-with-has-secure-password
    self.password = self.password_confirmation = "12345678"
    self.password_digest = "external-authorized account"

    # At this point user is no longer guest
    self.guest = false
    self.save!
  end

end
