class SessionsController < ApplicationController
  def new
    # binding.remote_pry
  end

  def create
    if auth_hash.nil?
      # Regular user name/password authentication
      user = User.find_by_email(params[:email])
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        puts "Session in Session#create #{session}"
        redirect_to session[:user_return_to], notice: "Logged in!"
      else
        flash.now.alert = "Email or password is invalid."
        redirect_to login_url
      end
    else
      # Omniauth callback
      user = User.find_or_create_from_auth_hash(auth_hash)
      if user
        session[:user_id] = user.id
        redirect_to session[:user_return_to], notice: "Logged in!"
      else
        flash.now.alert = "Facebook login invalid."
        redirect_to login_url
      end
    end
  end

  def failure
    # Omniauth failure
    flash.now.alert = "Facebook login invalid."
    redirect_to login_url
  end

  def destroy
    session[:user_id] = nil
    redirect_to params[:logout_callback], notice: "Logged out!"
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end