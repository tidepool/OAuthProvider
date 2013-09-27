class FitbitRegistration < BaseRegistration
  def populate(auth_hash)
    return if auth_hash.nil? || auth_hash.info.nil?
    # Rails.logger.info("Connected to Fitbit: #{auth_hash.info}\n #{auth_hash.extra.raw_info.user}")
    set_if_empty(:name, auth_hash.info.full_name)
    set_if_empty(:display_name, auth_hash.info.display_name)
    set_gender(auth_hash.info.gender)
    set_if_empty(:city, auth_hash.info.city)
    set_if_empty(:state, auth_hash.info.state)
    set_if_empty(:country, auth_hash.info.country)
    set_dob(auth_hash.info.dob)
    set_if_empty(:timezone, auth_hash.info.timezone)
    set_if_empty(:locale, auth_hash.info.locale)

    if auth_hash.extra && auth_hash.extra.raw_info && auth_hash.extra.raw_info.user
      set_if_empty(:image, auth_hash.extra.raw_info.user.avatar)
      @authentication.timezone = auth_hash.extra.raw_info.user.timezone
      @authentication.timezone_offset = auth_hash.extra.raw_info.user.offsetFromUTCMillis.to_i / 1000
    end
  end

  def create_subscription
    client = Fitgem::Client.new(client_config)
    if client.nil?
      Rails.logger.error("ProviderError: Cannot create Fitgem to connect to fitbit.")
      return
    end
    opts = {
      type: :all,  # Subscribe to all notifications
      subscription_id: @user.id
    }
    code, response = client.create_subscription(opts)
    if code == 409
      Rails.logger.error("ProviderError: User #{@user.id} already subscribed.")
      @authentication.subscription_info = 'failed'  
      return    
    end
    Rails.logger.info("Subscription created!")
    @authentication.subscription_info = 'subscribed'
  end

  def client_config
    {
      consumer_key: ENV['FITBIT_KEY'],
      consumer_secret: ENV['FITBIT_SECRET'],
      token: @authentication.oauth_token,
      secret: @authentication.oauth_secret,
      user_id: @authentication.uid
    }
  end  
end
