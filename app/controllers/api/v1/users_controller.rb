class Api::V1::UsersController < Api::V1::ApiController
  doorkeeper_for :index, :show, :create, :update, :destroy

  def index
    # TODO: Consider queries like friends, latest_users etc.
  end

  def show
    user = current_resource

    respond_to do |format|
      format.json { render :json => user }
    end
  end

  def finish_login
    user = current_resource
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
  end

  def create
    # if params[:guest_id]
    #   # Transfer a Guest User to registered user
    #   @user = User.find(params[:guest_id])
    #   @user.update(params[:user])
    # else
    #   @user = User.new(params[:user])
    # end
    user = User.create!(user_attributes)
    respond_to do |format|
      format.json { render :json => user }
    end
  end

  def update
    user = current_resource
    user.update_attributes(user_attributes)

    respond_to do |format|
      format.json { render :json => @user}
    end
  end

  def destroy
    user = current_resource
    user.destroy
  end 

  private 

  def current_resource
    if params[:id] == '-' || params[:id] == 'finish_login'
      @user ||= caller
    else
      @user ||= User.find(params[:id])
    end
  end

  def user_attributes
    if (caller && caller.admin?)
      params.require(:user).permit!
    else
      params.require(:user).permit
        :email, :password, :name, :display_name, 
        :description, :city, :state, :country, :timezone, 
        :locale, :image, :gender, :date_of_birth
    end
  end
end