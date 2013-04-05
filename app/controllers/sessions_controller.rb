class SessionsController < ApplicationController
  def new
    # binding.remote_pry
  end

  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      puts "Session in Session#create #{session}"
      redirect_to session[:user_return_to], notice: "Logged in!"
    else
      flash.now.alert = "Email or password is invalid."
      redirect_to login_url
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to params[:logout_callback], notice: "Logged out!"
  end
end