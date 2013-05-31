class AuthenticationsController < ApplicationController
  def create
    # binding.remote_pry
    auth_hash = request.env['omniauth.auth']

    user_id = session[:user_id]
    redirect_after_external = session[:redirect_after_external]

    user = User.create_or_find(auth_hash, user_id)
    if user.nil?
      user_id = -1
    else
      user_id = user.id
    end
    clean_up_session
    redirect_url = "#{redirect_after_external}user_id=#{user_id}&provider=#{auth_hash.provider}" 
    redirect_to redirect_url
  end

  def failure
    # Omniauth failure

    redirect_url = "#{session[:redirect_after_external]}user_id=-1" 
    clean_up_session
    redirect_to redirect_url
  end

  def add_new
    # We are creating this authentication using the browser redirect method  
    session[:redirect_after_external] = params[:redirect_uri]
    session[:user_id] = params[:user_id]
    authentication_uri = "/auth/#{params[:provider]}"

    redirect_to authentication_uri    
  end

  private 

  def clean_up_session
    session[:user_id] = nil
    session[:redirect_after_external] = nil
  end
end
