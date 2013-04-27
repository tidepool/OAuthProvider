class Api::V1::AuthenticationsController < Api::V1::ApiController
  doorkeeper_for :all

  def index
    user = determine_user

    if user
      authentications = user.authentications.find_all
      respond_to do |format|
        format.json { render :json => response_body, :status => :ok }   
      end
    else
     response_body = {
       :error => "Only admins or current user can invoke this operation."
     }
     respond_to do |format|
       format.json { render :json => response_body, :status => :unauthorized }  
    end  
  end

  def create
    if current_resource_owner
      # This is an API call:
      # We expect the authentication token to passed to us.
      user = current_resource_owner
      # TODO: create the auth_hash here from parameters passed-in
      # auth_hash = {}
      # user.populate_from_auth_hash(auth_hash)
    end
  end

  def destroy
    user = determine_user
    if user
      authentication = user.authentications.find(params[:id])
      if authentication
        authentication.destroy
        response_body = {
          :message => "Authentication deleted."
        }
        respond_to do |format|
          format.json { render :json => response_body, :status => :ok }   
        end
      end
    else
     response_body = {
       :error => "Only admins or current user can invoke this operation."
     }
     respond_to do |format|
       format.json { render :json => response_body, :status => :unauthorized }  
    end
  end

  private
  def determine_user
    # Only current_resource_owner or an admin can interact with authentications
    user = current_resource_owner
    if user.nil?
      # Could be an admin calling this?
      user = User.find(params[:id])
      if user 
        user = user.admin? ? user : nil
      end
    end
    user
  end
end