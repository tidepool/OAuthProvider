class Api::V1::FriendsController < Api::V1::ApiController
  doorkeeper_for :all

  def index
    user = check_params(params)

    friends, api_status = User.paginate(user.friends.select(['users.id', :name, :image]), params)
    respond_to do |format|
      format.json { render({ json: friends, each_serializer: FriendSummarySerializer, meta: api_status }.merge(api_defaults)) }
    end
  end

  def pending
    user = check_params(params)

    friends_service = FriendsService.new
    api_status, friends = friends_service.find_pending_friends(user.id, params)
    response = {
      data: friends,
      status: api_status
    }
    respond_to do |format|
      format.json { render( json: response.to_json ) }
    end
  end

  def accept
    friend_ops do |user, friend_list, friends_service| 
      friends_service.accept_friends(user.id, friend_list)
      'Friend list accepted.'
    end
  end

  def reject
    friend_ops do |user, friend_list, friends_service| 
      friends_service.reject_invitations(user.id, friend_list)
      'Friend list rejected.'
    end
  end

  def unfriend
    friend_ops do |user, friend_list, friends_service| 
      friends_service.unfriend_friends(user.id, friend_list)
      'Friend list unfriended.'
    end
  end

  def find
    user = check_params(params)

    email_list = params[:email]
    fb_list = params[:fbid]

    friend_list = {
      emails: email_list,
      facebook_ids: fb_list
    }

    friends_service = FriendsService.new
    new_found_friends = friends_service.find_new_friends(user.id, friend_list)

    api_status = Hashie::Mash.new( {'total' => new_found_friends.length} )
    response = {
      data: new_found_friends,
      status: api_status
    }
    respond_to do |format|
      format.json { render( json: response.to_json ) }
    end    
  end

  def invite
    friend_ops do |user, friend_list, friends_service| 
      friends_service.invite_friends(user.id, friend_list)
      'Friend list invited, once they accept they will be your friends.'
    end
  end

  private
  def current_resource
    target_user
  end

  def friend_ops(&block)
    user = check_params(params)

    friend_list = params[:friend_list]
    raise ArgumentError, "No friend list is specified." if friend_list.nil? || friend_list.empty?

    friends_service = FriendsService.new
    message = block.call(user, friend_list, friends_service)

    api_status = Hashie::Mash.new({state: :accepted, message: message})
    respond_to do |format|
     format.json { render({ json: nil, status: :accepted, meta: api_status, serializer: FriendSummarySerializer }.merge(api_defaults) ) }
    end               
  end

  def check_params(params)
    limit = (params[:limit] || 20).to_i 
    offset = (params[:offset] || 0).to_i
    raise Api::V1::NotAcceptableError, "Limit cannot be larger than 20." if limit > 20

    user = current_resource
    raise Api::V1::NotAcceptableError, "User not specified." if user.nil?

    user
  end
end