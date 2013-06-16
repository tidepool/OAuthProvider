class Api::V1::PreordersController < Api::V1::ApiController
  doorkeeper_for :create

  def create
    preorder = current_resource.preorders.create
    respond_to do |format|
      format.json { render :json => preorder }
    end

  end

  protected

  def current_resource
    if params[:user_id]
      user_id = params[:user_id]
      if user_id && user_id == '-'
        @user = caller
      elsif user_id 
        @user = User.find(params[:user_id])
      end
    end
    @user
  end

  def preorder_attributes
    params.require(:preorder).permit()
  end
end