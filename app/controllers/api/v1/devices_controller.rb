class Api::V1::DevicesController < Api::V1::ApiController
  doorkeeper_for :all

  def index 
    query = Device.where(user_id: target_user.id)
    query = query.where(os: params[:os]) unless params[:os].nil?

    devices, api_status = Device.paginate(query, params) 

    respond_to do |format|
      format.json { render({ json: devices, meta: api_status, each_serializer: DeviceSerializer }.merge(api_defaults))  }
    end
  end

  def create
    device = Device.new(device_attributes)
    device.user = target_user
    device.save!

    respond_to do |format|
      format.json { render({ json: device, meta: {} }.merge(api_defaults))  }
    end    
  end

  def show
    device = Device.find(params[:id])

    respond_to do |format|
      format.json { render({ json: device, meta: {} }.merge(api_defaults))  }
    end
  end

  def update
    device = Device.find(params[:id])
    device.update_attributes(device_attributes)

    respond_to do |format|
      format.json { render({ json: device, meta: {} }.merge(api_defaults))  }
    end    
  end

  def destroy
    device = Device.find(params[:id])
    device.destroy!

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