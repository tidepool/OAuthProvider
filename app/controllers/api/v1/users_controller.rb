class Api::V1::UsersController < Api::V1::ApiController
  doorkeeper_for :index, :show, :update, :destroy

  def index
    # TODO: Consider queries like friends, latest_users etc.
  end

  def show
    user = current_resource

    respond_to do |format|
      format.json { render :json => user }
    end
  end

  def create
    user = User.create_guest_or_registered!(user_attributes)
    respond_to do |format|
      format.json { render :json => user }
    end
  end

  def update
    user = current_resource
    if user.guest == false && params[:user][:guest]
      raise Api::V1::UnauthorizedError.new('Not Authorized')
    end

    # TODO: We should be using the ! version here, but
    # looks like it fails even no password is supposed to be set.
    user.update_attributes(user_attributes)

    respond_to do |format|
      format.json { render :json => @user}
    end
  end

  def destroy
    user = current_resource
    user.destroy
    respond_to do |format|
      format.json { render :json => {}}
    end
  end 

  private 

  def current_resource
    if params[:id] == '-' || params[:action] == 'finish_login'
      @user ||= caller
    elsif params[:id]
      @user ||= User.find(params[:id])
    else
      @user = nil
    end
  end

  def user_attributes
    if (caller && caller.admin?)
      params.require(:user).permit!
    elsif params[:action] == 'create'
      params.require(:user).permit(:guest,
      :email, :password, :password_confirmation, :name, :display_name, 
      :description, :city, :state, :country, :timezone, 
      :locale, :image, :gender, :date_of_birth)        
    else
      params.require(:user).permit(:guest,
        :email, :password, :password_confirmation, :name, :display_name, 
        :description, :city, :state, :country, :timezone, 
        :locale, :image, :gender, :date_of_birth)
    end
  end
end