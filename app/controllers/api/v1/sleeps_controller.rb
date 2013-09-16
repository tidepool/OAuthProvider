class Api::V1::SleepsController < Api::V1::ApiController
  doorkeeper_for :all

  def index
    query = Sleep.where(user_id: target_user)
    query = query.where(provider: params[:provider]) if params[:provider]
    query = query.order(:date_recorded)

    sleeps, api_status = Sleep.paginate(query, params)

    respond_to do |format|
      format.json { render({ json: sleeps, meta: api_status }.merge(api_defaults))  }
    end
  end

  def current_resource
    target_user
  end
end