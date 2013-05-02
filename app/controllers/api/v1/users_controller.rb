class Api::V1::UsersController < Api::V1::ApiController
  doorkeeper_for :index, :show, :update, :destroy

  def index

  end

  def show
    user = nil
    if params[:id] == "finish_login" 
      user = current_resource_owner
      if params[:guest_id] && params[:guest_id] != 'null'
        # There is a prior guest, we need to transfer their assessment to the new user
        assessment = Assessment.where('user_id = ?', params[:guest_id]).last
        if assessment
          assessment.user_id = user.id 
          assessment.save!
        end 
      end
      respond_to do |format|
        format.json { render :json => user }
      end
    elsif params[:id] == "-" ||  params[:id].to_i == current_resource_owner.id
      # Get the resource owner
      user = current_resource_owner

      respond_to do |format|
        format.json { render :json => user }
      end
    elsif current_resource_owner.admin?
      user = User.find(params[:id])
      respond_to do |format|
        format.json { render :json => user }
      end
    else
      response_body = {
        :error => {
          :message => 'Only users themselves and admins can get user info'
        }
      }
      respond_to do |format|
        format.json { render :json => response_body, :status => :unauthorized }
      end
    end
  end

  def create
    # binding.remote_pry
    if params[:guest_id]
      # Transfer a Guest User to registered user
      @user = User.find(params[:guest_id])
      @user.update(params[:user])
    else
      @user = User.new(params[:user])
    end
    if @user.save
      respond_to do |format|
        format.json { render :json => @user }
      end
    else
      response_body = {
        :error => {
          :message => 'User can not be created'
        }
      }
      format.json { render :json => response_body, :status => :internal_server_error }
    end
  end

  def update

  end
end