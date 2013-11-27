class Api::V1::ActivityStreamController < Api::V1::ApiController
  doorkeeper_for :all

  def index
    user = check_params(params)

    activity_stream = ActivityStreamService.new
    activities, api_status = activity_stream.read_activity_stream(user.id, params)

    respond_to do |format|
      format.json { render({ json: activities, each_serializer: ActivityStreamSerializer, meta: api_status }.merge(api_defaults)) }
    end
  end


  private
  def check_params(params)
    limit = (params[:limit] || 20).to_i 
    offset = (params[:offset] || 0).to_i
    raise Api::V1::NotAcceptableError, "Limit cannot be larger than 20." if limit > 20

    user = current_resource
    raise Api::V1::NotAcceptableError, "User not specified." if user.nil?

    user
  end

  def current_resource
    target_user
  end
end