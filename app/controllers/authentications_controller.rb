class AuthenticationsController < ApplicationController
  def create
    # binding.remote_pry
    auth_hash = request.env['omniauth.auth']
    authentication = Authentication.find_by_provider_and_uid(auth_hash.provider, auth_hash.uid)
    user = nil
    if authentication
      user = authentication.user
    elsif session[:user_id]
      # We are trying to add the new authentication by provider to the user
      user = session[:user_id]
      user.populate_from_auth_hash!(auth_hash)
      # We do not want the session variable to stick around after
      session[:user_id] = nil
    else
      user = User.new
      user.populate_from_auth_hash!(auth_hash)
    end
    redirect_url = "#{session[:user_return_to]}&user_id=#{user.id}&provider=#{auth_hash.provider}" 
    session[:user_return_to] = nil
    redirect_to redirect_url
  end

  def failure
    # Omniauth failure
    flash.now.alert = "Facebook login invalid."
    redirect_url = "#{session[:user_return_to]}" 
    session[:user_return_to] = nil
    redirect_to redirect_url
  end

  def additional
    # We are creating this authentication using the browser redirect method  
    session[:user_return_to] = params[:redirect_uri]
    session[:user_id] = params[:user_id]
    authentication_uri = "/auth/#{params[:provider]}"

    redirect_to authentication_uri    
  end
end
