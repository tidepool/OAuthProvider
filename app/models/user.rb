# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string(255)      default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)      default(""), not null
#  admin           :boolean          default(FALSE), not null
#  guest           :boolean          default(FALSE), not null
#  name            :string(255)
#  display_name    :string(255)
#  description     :string(255)
#  city            :string(255)
#  state           :string(255)
#  country         :string(255)
#  timezone        :string(255)
#  locale          :string(255)
#  image           :string(255)
#  gender          :string(255)
#  date_of_birth   :date
#  handedness      :string(255)
#  orientation     :string(255)
#  education       :string(255)
#  referred_by     :string(255)
#  stats           :hstore
#

class User < ActiveRecord::Base
  has_secure_password validations: false
  
  # Dir[File.expand_path('../auth_providers/*.rb', __FILE__)].each do |file|
  #   require file 
  #   module_name = File.basename(file, '.rb').camelize 
  #   include Object.const_get(module_name)
  # end

  validates_uniqueness_of :email
  validates_format_of :email, :with => /.+@.+\..+/i
  validates :password, :length => { :minimum => 8 }, :if => :needs_password?, on: :create
  validates_confirmation_of :password

  has_one :personality
  has_many :authentications
  has_many :preorders
  has_many :results
  has_many :aggregate_results
  has_many :preferences
  has_many :activities

  # def self.create_guest_or_registered(attributes)
  #   begin
  #     User.create_guest_or_registered!(attributes)
  #   rescue Exception => e
  #     logger.error("Creating a user with username and password raised an error: #{e.message}")
  #     nil
  #   end
  # end

  # def self.create_guest_or_registered!(attributes)
  #   user = User.new(attributes)
  #   if user.guest
  #     user.email = "guest_#{Time.now.to_i}#{rand(99)}@example.com"
  #     user.password = user.password_confirmation = "12345678"
  #     user.password_digest = "Tidepool-Guest-User"
  #   end
  #   user.save!
  #   user
  # end

  # def self.create_or_find(auth_hash, user_id = nil)
  #   begin
  #     User.create_or_find!(auth_hash, user_id)
  #   rescue Exception => e
  #     logger.error("Creating a user with #{auth_hash} raised an error: #{e.message}")
  #     nil
  #   end
  # end

  # def self.create_or_find!(auth_hash, user_id = nil)
  #   user = nil
  #   # binding.remote_pry
  #   # First check if the authentication already exists:
  #   authentication = Authentication.find_by_provider_and_uid(auth_hash.provider, auth_hash.uid)
  #   if authentication
  #     logger.info("AuthenticationSequence: Authentication found!")
  #     if user_id
  #       user = User.find(user_id)
  #       logger.info("AuthenticationSequence: A user_id is passed and user found!")
  #       if user != authentication.user && user.guest == false
  #         logger.info("AuthenticationSequence: Authentication user and user found does not matching. Transferring authentication!")
  #         # We need to transfer the user over
  #         authentication.user = user
  #         user.populate_from_provider(auth_hash, authentication)
  #         user.save!
  #       end
  #     end
  #     authentication.check_and_reset_credentials(auth_hash)
  #     authentication.save!
  #     user = authentication.user
  #     if user && user.guest
  #       logger.warn("AuthenticationSequence: Authentication user is guest, this is abnormal!")
  #       # Ensure that user is not guest
  #       user.guest = false
  #       user.save!
  #     elsif user.nil?
  #       logger.warn("AuthenticationSequence: Authentication does not have a user. Will delete the authentication, this is abnormal!")
  #       authentication.destroy!
  #     end
  #   else
  #     if user_id
  #       logger.info("AuthenticationSequence: No authentication found, but a user_id is passed, will try finding the user.")      
  #       # We are trying to add the new authentication by provider to the user (The user can be a guest)
  #       # Note that user_id being nil means we are not even trying to find the user.
  #       user = User.where('id = ?', user_id).first
  #       if user
  #         user.populate_from_auth_hash!(auth_hash) 
  #       else
  #         logger.error("AuthenticationSequence: Invalid or non-existing user_id #{user_id} was passed, user not found!")
  #       end
  #     else
  #       # The user does not exist (even no guest existed that needs mutation)
  #       logger.info("AuthenticationSequence: No authentication found, and no user_id is passed, will create a brand new user.")      
  #       user = User.new
  #       if user
  #         user.populate_from_auth_hash!(auth_hash) 
  #       else
  #         logger.error("AuthenticationSequence: Very unexpected, just trying to create a user in memory and failed!")
  #       end
  #     end  
  #   end
  #   user
  # end

  def needs_password?
    guest == false #&& (password.present? || password_confirmation.present?)
  end

  # def set_if_empty(property, value, authentication)
  #   authentication[property] = value
  #   if self[property].nil? || (self[property].class == String && self[property].empty?) || self.guest
  #     self[property] = value
  #   end
  # end

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

  # def populate_from_auth_hash!(auth_hash)
  #   if auth_hash.nil?  
  #     logger.error("AuthenticationSequence: Auth_hash is not provided, returning without adding the authentication.")
  #     return
  #   end 
  #   provider = auth_hash.provider 
  #   if provider.nil? || provider.empty?
  #     logger.error("AuthenticationSequence: Auth_hash does not include provider info, returning.")
  #     return
  #   end 

  #   no_existing_authentications = self.authentications.empty? 
  #   logger.info("AuthenticationSequence: Received the hash, building a new Authentication.")
  #   authentication = self.authentications.build(:provider => provider, :uid => auth_hash.uid)
  #   authentication.check_and_reset_credentials(auth_hash)
  #   populate_from_provider(auth_hash, authentication)
  #   authentication.save!

  #   # As suggested here: (to prevent the password validation failing)
  #   # http://stackoverflow.com/questions/11917340/how-can-i-sometimes-require-password-and-sometimes-not-with-has-secure-password

  #   # Case 1:
  #   #   User has primary authentication as TidePool Registered with email and password
  #   #   (guest is false)
  #   #   Adding a new authentication
  #   #   password_digest is not empty
  #   #   Should not reset the password
  #   # Case 2:
  #   #   User has primary authentication as Facebook. 
  #   #   (guest is false)
  #   #   Adding a new authentication
  #   #   password_digest = "external-authorized account"
  #   #   Resetting the password has no effect. Ideally not reset the password.
  #   # Case 3:
  #   #   User has no authentication, guest user.
  #   #   (guest is true)
  #   #   Authenticating first time (with Facebook)
  #   #   password_digest = "Tidepool-Guest-User"
  #   #   Resetting the password has no effect. User had a Guest Password Digest, will now have an External one if we reset.
  #   # Case 4:
  #   #   User has no authentication, not a guest user.
  #   #   (guest is false)
  #   #   Authenticating first time (with Facebook)
  #   #   password_digest = ""
  #   #   We need to set a password so that the user.save! does not fail for validation
  #   if self.password_digest.nil? || self.password_digest.empty?
  #     logger.info("AuthenticationSequence: Guest user is adding external authentication, rewriting the password_digest.")
  #     self.password = self.password_confirmation = "12345678"
  #     self.password_digest = "external-authorized account"
  #   end

  #   # At this point user is no longer guest
  #   self.guest = false
  #   self.save!
  # end

  # def populate_from_provider(auth_hash, authentication)
  #   provider = authentication.provider
  #   method_name = "populate_from_#{provider.underscore}".to_sym
  #   if self.method(method_name)
  #     self.method(method_name).call(auth_hash, authentication) 
  #   else
  #     logger.error("AuthenticationSequence: No method #{method_name} found while populating from provider.")
  #   end
  # end

end
