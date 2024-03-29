class Api::V1::UsersController < Api::V1::ApiController
  doorkeeper_for :index, :show, :update, :destroy

  # TODO: This is stupid!
  # https://github.com/rails/rails/issues/10630
  
  wrap_parameters User, include: [:guest,
      :email, :password, :password_confirmation, :name, :display_name, 
      :description, :city, :state, :country, :timezone, 
      :locale, :image, :gender, :date_of_birth, :education, :handedness, :referred_by, 
      :ios_device_token, :android_device_token, :is_dob_by_age]

  def index
    # TODO: Consider queries like friends, latest_users etc.
  end

  def show
    if caller == current_resource
      # The caller is asking about themselves.
      user = user_eager_load
      serializer = UserSerializer
    else
      # The caller is asking about another user
      friend_service = FriendsService.new
      friend_status = friend_service.friend_status(caller, current_resource)
      serializer = friend_status == :friend ? FriendSerializer : PublicProfileSerializer
      user = current_resource
      user.friend_status = friend_status
    end

    respond_to do |format|
      format.json { render({ json: user, serializer: serializer, meta: {} }.merge(api_defaults)) }
    end
  end

  def reset_password
    registration_service = RegistrationService.new
    registration_service.reset_password(params[:user][:email])

    status = Hashie::Mash.new({
        message: "Password is reset, and email sent with temporary password."
      })
    respond_to do |format|
      format.json { render({ json: nil, meta: status, serializer: UserSerializer }.merge(api_defaults)) }
    end
  end

  def personality
    # TODO: DEPRECATE THIS, USER ALREADY RETURNS PERSONALITY
    user = current_resource

    respond_to do |format|
      format.json { render({ json: user.personality, meta: {} }.merge(api_defaults)) }
    end
  end

  def create
    registration_service = RegistrationService.new
    user = registration_service.register_guest_or_full!(user_attributes)

    respond_to do |format|
      format.json { render({ json: user, meta: {}, serializer: UserNewSerializer }.merge(api_defaults)) }
    end
  end

  def update
    # user = current_resource
    user = user_eager_load

    # TODO: We should be using the ! version here, but
    # looks like it fails even no password is supposed to be set.
    user.update_attributes(user_attributes)

    # Whenever guest calls update, they are not guest anymore!    
    user.guest = false

    # TODO: THIS NEEDS TO BE BETTER HANDLED!
    status = user.save!
    
    respond_to do |format|
      format.json { render({ json: user, meta: {} }.merge(api_defaults)) }
    end
  end

  def destroy
    user = current_resource
    user.destroy
    respond_to do |format|
      format.json { render({ json: user, meta: {} }.merge(api_defaults)) }
    end
  end 

  private 
  def user_eager_load
    user_id = params[:id].nil? || params[:id] == '-' ? caller.id : params[:id]
    user = User.eager_load(:personality, :authentications, :aggregate_results).where(id: user_id).first
  end

  def current_resource
    if params[:id]
      target_user_for(params[:id])
    elsif params[:user_id]
      target_user_for(params[:user_id])
    else
      nil
    end
  end

  def user_attributes
    if (caller && caller.admin?)
      params.require(:user).permit!
    elsif params[:action] == 'create'
      params.require(:user).permit(:guest,
        :email, :password, :password_confirmation, :name, :display_name, 
        :description, :city, :state, :country, :timezone, 
        :locale, :image, :gender, :date_of_birth, :education, :handedness, :referred_by, 
        :ios_device_token, :android_device_token, :is_dob_by_age)        
    else
      params.require(:user).permit(:guest,
        :email, :password, :password_confirmation, :name, :display_name, 
        :description, :city, :state, :country, :timezone, 
        :locale, :image, :gender, :date_of_birth, :education, :handedness, :referred_by, 
        :ios_device_token, :android_device_token, :is_dob_by_age)
    end
  end
end