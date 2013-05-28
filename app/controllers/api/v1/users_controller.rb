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

  def finish_login
    user = current_resource
    if params[:guest_id] && params[:guest_id] != 'null'
      # There is a prior guest, we need to transfer their game to the new user
      game = Game.where('user_id = ?', params[:guest_id]).last
      if game
        game.user_id = user.id 
        game.save!
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
    else
      params.require(:user).permit(
        :email, :password, :password_confirmation, :name, :display_name, 
        :description, :city, :state, :country, :timezone, 
        :locale, :image, :gender, :date_of_birth)
    end
  end
end