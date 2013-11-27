class Api::V1::HighfivesController < Api::V1::ApiController
  doorkeeper_for :all

  def index 
    query = Highfive.joins(:user).select("highfives.*, users.email as user_email, users.name as user_name, users.image as user_image")
    query = query.where(activity_record_id: params[:activity_record_id])
    highfives, api_status = Highfive.paginate(query, params) 

    respond_to do |format|
      format.json { render({ json: highfives, meta: api_status, each_serializer: HighfiveSummarySerializer }.merge(api_defaults))  }
    end
  end

  def create
    highfive = Highfive.new
    highfive.activity_record_id = params[:activity_record_id].to_i
    highfive.user = target_user
    highfive.save!

    respond_to do |format|
      format.json { render({ json: highfive, meta: {} }.merge(api_defaults))  }
    end    
  end

  def destroy
    highfive = Highfive.find(params[:id])
    highfive.destroy!

    respond_to do |format|
      format.json { render({ json: {}, meta: {} }.merge(api_defaults))  }
    end        
  end

  private 
  def current_resource
    target_user
  end

end