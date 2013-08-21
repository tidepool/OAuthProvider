require 'pry-remote' if Rails.env.test? || Rails.env.development?

Doorkeeper.configure do
  # Change the ORM that doorkeeper will use.
  # Currently supported options are :active_record, :mongoid2, :mongoid3, :mongo_mapper
  orm :active_record

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    # puts "Resource_owner authenticator called #{request.params}"
    user_id = params[:user_id]
    guest_id = params[:guest_id]
    provider = params[:provider]

    if user_id && user_id != -1
      user = User.find(user_id)
    else
      if provider
        session[:user_id] = guest_id if guest_id
        # The & at the end is necessary as we will tack parameters
        session[:redirect_after_external] = "#{request.fullpath}&"
        redirect_to("/auth/#{provider}")
        # Once the authentication is complete (success of fail), 
        # we will be redirected back here with a user_id in the params
      end
    end
  end

  # Facebook or (other) based external authenticated signup
  # {
  #   "user_id" : "Tidepool user id if exists",
  #   "client_id" : "App Client ID",
  #   "client_secret" : "App Client Secret",  
  #   "grant_type" : "password",               # Use the string "password" literally here
  #   "response_type" : "password",            # Use the string "password" literally here
  #   "auth_hash": 
  #     {
  #       "provider": "facebook",
  #       "uid": "facebook user id",           # Maps to com.facebook.sdk:TokenInformationUserFBIDKey
  #       "info": {
  #         "email": "email",
  #         "name": "name",
  #         "image": "image_url",
  #         "location" : "location",
  #         "gender" : "male",
  #         "dob" : "1911-11-23"
  #       },
  #       "extra": {
  #         "raw_info": {
  #           "gender" : "male",
  #           "dob" : "1911-11-23"
  #         }
  #       },
  #       "credentials": {
  #         "token": "facebook token",                      # Maps to com.facebook.sdk:TokenInformationTokenKey
  #         "secret": "for Oauth 1.0 providers only",
  #         "refresh_at": "2013-07-31T15:17:35.520-0700",   # Maps to com.facebook.sdk:TokenInformationRefreshDateKey
  #         "permissions": ["basic_info","publish_actions"],# Maps to com.facebook.sdk:TokenInformationPermissionsKey
  #         "expires_at": "2013-09-28T19:44:46.520-0700",   # Maps to com.facebook.sdk:TokenInformationExpirationDateKey
  #         "expires": true
  #       }
  #     }
  # }
  # Below is what Facebook mappings look like: (https://github.com/colene/FacebookConnect/blob/master/src/ios/facebook/FBSessionTokenCachingStrategy.m)
  # { 
  #   "com.facebook.sdk:TokenInformationExpirationDateKey": "2013-09-28T19:44:46.520-0700",
  #   "com.facebook.sdk:TokenInformationUserFBIDKey": "",
  #   "com.facebook.sdk:TokenInformationTokenKey" : "CAAGrx0SD4AQBAPwlnVJGklqAxgQ99MQEKnLyoVuWvJH2Se5Ue8DE0L0ZBl74p8mFRc4KV43ZCXLnbocjH0YehdldzzklRAkI5SgVS17PNQZBdYkh6LXLlnDyDhxoXWZAMU3rDhgmZAQuA2wR5mdFuZCoXKF3UD9YjE3U5JXSwqvHX2Vqq4MyB1uCA4Sok28UgZD",
  #   "com.facebook.sdk:TokenInformationRefreshDateKey" : "2013-07-31T15:17:35.520-0700", 
  #   "com.facebook.sdk:TokenInformationLoginTypeLoginKey" : 3,
  #   "com.facebook.sdk:TokenInformationPermissionsKey": ["basic_info","publish_actions"]
  # }


  # Below gets called in from our client when:
  # response_type: password
  resource_owner_from_credentials do |routes|
    # binding.remote_pry
    registration_service = RegistrationService.new

    if params[:auth_hash]
      user_id = params[:user_id]
      auth_hash = Hashie::Mash.new(params[:auth_hash])

      # user = User.create_or_find(auth_hash, user_id)
      user = registration_service.register_or_find_from_external(auth_hash, user_id)
    else
      username = params[:email] || params[:username]
      password = params[:password]

      user = User.where('email = ?', username).first
      if user.nil?
        if params[:guest] != nil
          guest = params[:guest]
        else
          guest = false
        end
        attributes = {
          email: username,
          password: password,
          password_confirmation: params[:password_confirmation],
          guest: guest
        }
        # return_user = User.create_guest_or_registered(attributes)
        return_user = registration_service.register_guest_or_full(attributes)
      else
        return_user = user && (user.guest || user.authenticate(password)) ? user : nil         
      end
    end
  end

  # If you want to restrict access to the web interface for adding oauth authorized applications, you need to declare the block below.
  # admin_authenticator do
  #   # Put your admin authentication logic here.
  #   # Example implementation:
  #   Admin.find_by_id(session[:admin_id]) || redirect_to(new_admin_session_url)
  # end

  # Authorization Code expiration time (default 10 minutes).
  # authorization_code_expires_in 10.minutes

  # Access token expiration time (default 2 hours).
  # If you want to disable expiration, set this to nil.
  access_token_expires_in 1.month

  # Issue access tokens with refresh token (disabled by default)
  use_refresh_token

  # Provide support for an owner to be assigned to each registered application (disabled by default)
  # Optional parameter :confirmation => true (default false) if you want to enforce ownership of
  # a registered application
  # Note: you must also run the rails g doorkeeper:application_owner generator to provide the necessary support
  # enable_application_owner :confirmation => false

  # Define access token scopes for your provider
  # For more information go to https://github.com/applicake/doorkeeper/wiki/Using-Scopes
  # default_scopes  :public
  # optional_scopes :write, :update

  # Change the way client credentials are retrieved from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:client_id` and `:client_secret` params from the `params` object.
  # Check out the wiki for more information on customization
  # client_credentials :from_basic, :from_params

  # Change the way access token is authenticated from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:access_token` or `:bearer_token` params from the `params` object.
  # Check out the wiki for mor information on customization
  # access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param

  # Change the test redirect uri for client apps
  # When clients register with the following redirect uri, they won't be redirected to any server and the authorization code will be displayed within the provider
  # The value can be any string. Use nil to disable this feature. When disabled, clients must provide a valid URL
  # (Similar behaviour: https://developers.google.com/accounts/docs/OAuth2InstalledApp#choosingredirecturi)
  #
  # test_redirect_uri 'urn:ietf:wg:oauth:2.0:oob'

  # Under some circumstances you might want to have applications auto-approved,
  # so that the user skips the authorization step.
  # For example if dealing with trusted a application.
  skip_authorization do |resource_owner, client|
    # TODO: When API is public, we should include our app as a super app and not skip authorization
    true
    # client.superapp? or resource_owner.admin?
  end
end
