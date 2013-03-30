class Api::V1::ProfilesController < Api::V1::ApiController
  doorkeeper_for :all

  def index
  end

  def show
  end

  def me
    respond_to do |format|
      format.json { render :json => current_resource_owner }
    end
  end
end
