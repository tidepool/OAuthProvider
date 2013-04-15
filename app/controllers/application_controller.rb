class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user 
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    else
      @current_user = nil
    end
  end

  def sign_in_and_redirect(user)
    session[:user_id] = user.id
    redirect_to session[:user_return_to], notice: "Logged in!"
  end 

  helper :current_user
  helper :sign_in_and_redirect
end
