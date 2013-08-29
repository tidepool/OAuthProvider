class AuthenticationsController < ApplicationController
  def create
    auth_hash = request.env['omniauth.auth']

    user_id = session[:user_id]
    redirect_after_external = session[:redirect_after_external]
    is_connection_request = session[:connection_request]
    # user = User.create_or_find(auth_hash, user_id)
    # binding.remote_pry
    registration_service = RegistrationService.new
    user = registration_service.register_or_find_from_external(auth_hash, user_id)
    if user.nil?
      user_id = -1
    else
      user_id = user.id
    end
    clean_up_session
    if is_connection_request
      redirect_url = redirect_after_external
    else
      redirect_url = "#{redirect_after_external}user_id=#{user_id}&provider=#{auth_hash.provider}" 
    end

    redirect_to redirect_url
  end

  def failure
    # Omniauth failure

    redirect_url = "#{session[:redirect_after_external]}user_id=-1" 
    clean_up_session
    redirect_to redirect_url
  end

  def client_redirect
    client_uri = session[:client_uri]
    redirect_to "#{client_uri}#{params[:access_token]}"
  end

  def add_new
    # We are creating this authentication using the browser redirect method  
    session[:redirect_after_external] = params[:redirect_uri]
    session[:user_id] = params[:user_id]
    session[:connection_request] = true
    authentication_uri = "/auth/#{params[:provider]}"

    redirect_to authentication_uri    
  end

  private 

  def clean_up_session
    session[:user_id] = nil
    session[:redirect_after_external] = nil
    session[:connection_request] = nil
  end
end
