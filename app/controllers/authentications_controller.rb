class AuthenticationsController < ApplicationController
  def create
    auth_hash = request.env['omniauth.auth']
    authentication = Authentication.find_by_provider_and_uid(auth_hash['provider'], auth_hash['uid'])
    user = nil
    if authentication
      user = authentication.user
    elsif current_user
      user = current_user
      user.populate_from_auth_hash!(auth_hash)
    else
      user = User.new
      user.populate_from_auth_hash!(auth_hash)
    end
    sign_in_and_redirect(user)
  end

  def failure
    # Omniauth failure
    flash.now.alert = "Facebook login invalid."
    redirect_to login_url
  end

  def destroy
    # TODO: Currently there is no UI to invoke this!
    authentication = current_user.authentications.find(params[:id])
    authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to login_url
  end
end
