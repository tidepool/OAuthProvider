class SessionsController < ApplicationController
  def new
  end

  def create
    admin = Admin.find_by_email(params[:email])
    if admin && admin.authenticate(params[:password])
      session[:admin_id] = admin.id
      if session[:return_to_admin]
        redirect_to session[:return_to_admin], notice: "Logged in!"
      else
        redirect_to root_url, notice: "Logged in!"
      end
    else
      flash.now.alert = "Email or password is invalid."
    end
  end

  def destroy
    session[:admin_id] = nil
    redirect_to new_session_path, notice: "Logged out!"
  end
end
