class Api::V1::NotificationsController < Api::V1::ApiController
  doorkeeper_for :all

  def index 
    not_service = NotificationService.new
    notifications, api_status = not_service.list_notifications(target_user.id, params)

    response = {
      data: notifications,
      status: api_status
    }
    respond_to do |format|
      format.json { render( json: response.to_json ) }
    end
  end

  def clear
    not_service = NotificationService.new
    not_service.clear_notifications(target_user.id)

    respond_to do |format|
      format.json { render({ json: {}, meta: {} }.merge(api_defaults))  }
    end        
  end

  private 

  def current_resource
    target_user
  end

  def device_attributes
    params.require(:device).permit(:name, :os, :os_version, :hardware, :token)  
  end
end