class Api::V1::ProfileDescriptionController < Api::V1::ApiController
  def show
    desc = ProfileDescription.where(display_id: params[:title]).first
    raise ActiveRecord::RecordNotFound, "#{params[:title]} is not a valid profile description." if desc.nil?

    respond_to do |format|
      format.json { render({ json: desc, meta: {} }.merge(api_defaults))  }
    end
  end
end