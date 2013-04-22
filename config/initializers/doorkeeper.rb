require 'pry-remote' if Rails.env.test? || Rails.env.development?

Doorkeeper.configure do
  # Change the ORM that doorkeeper will use.
  # Currently supported options are :active_record, :mongoid2, :mongoid3, :mongo_mapper
  orm :active_record

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    # raise "Please configure doorkeeper resource_owner_authenticator block located in #{__FILE__}"
    # Put your resource owner authentication logic here.
    # Example implementation:
    puts "Resource_owner authenticator called #{request.params}"
    # force_no_guest = params[:force_no_guest]  
    # session[:user_return_to] = request.fullpath

    puts "Session in Authenticator #{session}"    
    # binding.remote_pry
    user_id = params[:user_id]
    if user_id 
      user = User.find(user_id)
    else
      authorize_through = params[:authorize_through]
      if authorize_through
        redirect_to("/auth/#{authorize_through}")
        session[:user_return_to] = request.fullpath
      end
    end
    # user = User.find_by_email(params[:username])
    # user if user && user.authenticate(params[:password])
    # if force_no_guest
    #   puts "Has to use a real user not guest"
    #   current_user || redirect_to(login_url)
    # else  
    #   puts "Ok to creating a guest user" 
    #   user = current_user
    #   if user
    #     puts "Current User id is #{user.id}"
    #   end
    #   current_or_guest_user || redirect_to(login_url)
    # end
  end

  # Below gets called in from our client when:
  # response_type: password
  resource_owner_from_credentials do |routes|
    #binding.remote_pry

    puts "Resource_owner from credentials called #{routes}"
    if params[:email] == "guest"
      user = User.create(:email => "guest_#{Time.now.to_i}#{rand(99)}@example.com")
      user.guest = true
      user.save!(:validate => false)   
      user   
    else
      user = User.find_by_email(params[:email])
      user if user && user.authenticate(params[:password])
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
  # access_token_expires_in 2.hours

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
