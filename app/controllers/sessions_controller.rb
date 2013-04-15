class SessionsController < ApplicationController
  def new
    # binding.remote_pry
  end

  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      sign_in_and_redirect(user)
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