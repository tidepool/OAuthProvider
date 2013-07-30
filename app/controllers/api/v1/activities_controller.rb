class Api::V1::ActivitiesController < Api::V1::ApiController
  doorkeeper_for :all

  def index
    provider = params[:provider]
    if provider
      activities = Activity.where('user_id = ? and provider = ?', target_user, provider).order(:date_recorded)
    else
      activities = Activity.where('user_id = ?', target_user).order(:date_recorded)      
    end
    respond_to do |format|
      format.json { render({ json: activities, meta: {} }.merge(api_defaults))  }
    end
  end

  def current_resource
    target_user
  end

end