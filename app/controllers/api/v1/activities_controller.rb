class Api::V1::ActivitiesController < Api::V1::ApiController
  doorkeeper_for :all

  def index
    query = Activity.where(user_id: target_user)
    query = query.where(provider: params[:provider]) if params[:provider]
    query = query.order(:date_recorded)

    activities, api_status = Activity.paginate(query, params)

    respond_to do |format|
      format.json { render({ json: activities, meta: api_status, each_serializer: ActivitySerializer }.merge(api_defaults))  }
    end
  end

  def current_resource
    target_user
  end

end