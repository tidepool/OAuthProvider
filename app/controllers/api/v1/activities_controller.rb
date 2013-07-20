class Api::V1::ActivitiesController < Api::V1::ApiController
  doorkeeper_for :all

  def index


    respond_to do |format|
      format.json { render :json => activities }
    end
  end

  def current_resource
    target_user
  end

end