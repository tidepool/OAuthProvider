class Api::V1::UsersController < Api::V1::ApiController
  doorkeeper_for :index, :show, :update, :destroy

  def index

  end

  def show
    if params[:id] == "-"
      # Get the resource owner
      user = current_resource_owner
    elsif current_resource_owner.admin?
      user = User.find(params[:id]) 
    end

    respond_to do |format|
      format.json { render :json => user }
    end

  end

  def create
    # binding.remote_pry
    @user = User.new(params[:user])
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