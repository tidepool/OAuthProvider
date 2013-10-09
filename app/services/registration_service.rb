Dir[File.expand_path('../providers/*.rb', __FILE__)].each {|file| require file }

class RegistrationService
  def logger 
    ::Rails.logger
  end

  def reset_password(email)
    user = User.where(email: email).first
    raise ActiveRecord::RecordNotFound, "User with email does not exist" if user.nil?

    char_opts =  [('1'..'9'),('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
    password = (0...12).map{ char_opts[rand(char_opts.length)] }.join

    user.password = password
    user.password_confirmation = password
    user.save!

    MailSender.perform_async(:UserMailer, :password_reset_email, { user_id: user.id, temp_password: password } )
  end

  # def register_invited_user(email)
  #   user = User.new
  #   user.email = email
  #   user.guest = true
  #   user.password = user.password_confirmation = "12345678"
  #   user.password_digest = "Tidepool-Invited-User"
  #   user.save!
  #   user
  # end

  def register_guest_or_full(attributes)
    begin
      register_guest_or_full!(attributes)
    rescue Exception => e
      logger.error("Creating a user with username and password raised an error: #{e.message}")
      nil
    end
  end  

  def register_guest_or_full!(attributes)
    attributes[:password_confirmation] = "" if attributes[:password_confirmation].nil? # If nil password confirm validation does not work.
    user = User.new(attributes)
    if user.guest
      user.email = "guest_#{Time.now.to_i}#{rand(99)}@example.com"
      user.password = user.password_confirmation = "12345678"
      user.password_digest = "Tidepool-Guest-User"
    end
    user.save!
    send_welcome_email(user) unless user.guest == true
    user
  end

  def register_or_find_from_external(auth_hash, user_id = nil)
    begin
      register_or_find_from_external!(auth_hash, user_id)
    rescue Exception => e
      logger.error("Creating a user with #{auth_hash} raised an error: #{e.message}")
      nil
    end
  end

  def register_or_find_from_external!(auth_hash, user_id = nil)
    user = nil
    # binding.remote_pry
    # First check if the authentication already exists:
    authentication = Authentication.find_by_provider_and_uid(auth_hash.provider, auth_hash.uid)
    if authentication
      logger.info("AuthenticationSequence: Authentication found!")
      if user_id
        user = User.find(user_id)
        logger.info("AuthenticationSequence: A user_id is passed and user found!")
        if user != authentication.user && user.guest == false
          logger.info("AuthenticationSequence: Authentication user and user found does not matching. Transferring authentication!")
          # We need to transfer the user over
          authentication.user = user
          populate_from_provider(auth_hash, user, authentication)
          user.save!
        end
      end
      authentication.check_and_reset_credentials(auth_hash)
      authentication.save!
      user = authentication.user
      if user && user.guest
        logger.warn("AuthenticationSequence: Authentication user is guest, this is abnormal!")
        # Ensure that user is not guest
        user.guest = false
        user.save!
      elsif user.nil?
        logger.warn("AuthenticationSequence: Authentication does not have a user. Will delete the authentication, this is abnormal!")
        authentication.destroy!
      end
    else
      if user_id && !(user_id.class == String && user_id.empty?)
        logger.info("AuthenticationSequence: No authentication found, but a user_id is passed, will try finding the user.")      
        # We are trying to add the new authentication by provider to the user (The user can be a guest)
        # Note that user_id being nil means we are not even trying to find the user.
        user = User.where('id = ?', user_id).first
        mail_needs_to_be_sent = false
        mail_needs_to_be_sent = true if user.guest      
        if user
          populate_from_auth_hash!(auth_hash, user)
          send_welcome_email(user) if mail_needs_to_be_sent
        else
          logger.error("AuthenticationSequence: Invalid or non-existing user_id #{user_id} was passed, user not found!")
        end
      else
        # The user does not exist (even no guest existed that needs mutation)
        logger.info("AuthenticationSequence: No authentication found, and no user_id is passed, will create a brand new user.")      
        user = User.new
        if user
          populate_from_auth_hash!(auth_hash, user) 
          send_welcome_email(user)
        else
          logger.error("AuthenticationSequence: Very unexpected, just trying to create a user in memory and failed!")
        end
      end  
    end
    user
  end

  def populate_from_auth_hash!(auth_hash, user)
    if auth_hash.nil?  
      logger.error("AuthenticationSequence: Auth_hash is not provided, returning without adding the authentication.")
      return
    end 
    provider = auth_hash.provider 
    if provider.nil? || provider.empty?
      logger.error("AuthenticationSequence: Auth_hash does not include provider info, returning.")
      return
    end 

    no_existing_authentications = user.authentications.empty? 
    logger.info("AuthenticationSequence: Received the hash, building a new Authentication.")
    authentication = user.authentications.build(:provider => provider, :uid => auth_hash.uid)
    authentication.check_and_reset_credentials(auth_hash)
    populate_from_provider(auth_hash, user, authentication)
    authentication.save!

    # As suggested here: (to prevent the password validation failing)
    # http://stackoverflow.com/questions/11917340/how-can-i-sometimes-require-password-and-sometimes-not-with-has-secure-password

    # Case 1:
    #   User has primary authentication as TidePool Registered with email and password
    #   (guest is false)
    #   Adding a new authentication
    #   password_digest is not empty
    #   Should not reset the password
    # Case 2:
    #   User has primary authentication as Facebook. 
    #   (guest is false)
    #   Adding a new authentication
    #   password_digest = "external-authorized account"
    #   Resetting the password has no effect. Ideally not reset the password.
    # Case 3:
    #   User has no authentication, guest user.
    #   (guest is true)
    #   Authenticating first time (with Facebook)
    #   password_digest = "Tidepool-Guest-User"
    #   Resetting the password has no effect. User had a Guest Password Digest, will now have an External one if we reset.
    # Case 4:
    #   User has no authentication, not a guest user.
    #   (guest is false)
    #   Authenticating first time (with Facebook)
    #   password_digest = ""
    #   We need to set a password so that the user.save! does not fail for validation
    if user.password_digest.nil? || user.password_digest.empty?
      logger.info("AuthenticationSequence: Guest user is adding external authentication, rewriting the password_digest.")
      user.password = user.password_confirmation = "12345678"
      user.password_digest = "external-authorized account"
    end

    # At this point user is no longer guest
    user.guest = false
    user.save!
  end

  def populate_from_provider(auth_hash, user, authentication)
    provider = authentication.provider
    begin
      klass_name = "#{provider.camelize}Registration"
      populator = klass_name.constantize.new(user, authentication)
      populator.populate(auth_hash)
      authentication.save!  #TODO: This is an extra save, but we need this due to race condition below.
      subscribe_to_service_notifications(user, provider) if populator.respond_to?(:create_subscription)
    rescue Exception => e
      logger.error("ProviderError: Could not populate from #{provider}. Error: #{e.message}")
      # TODO : May be we should not eat this exception?
    end
  end

  def send_welcome_email(user)
    return if user.nil?
    MailSender.perform_async(:UserMailer, :welcome_email, { user_id: user.id } )
    NotifyInviter.perform_async(user.id, user.email)
  end

  def subscribe_to_service_notifications(user, provider)
    logger.info("About to create subscription for #{user.id}")
    Subscriber.perform_async(user.id, provider)
  end
end
