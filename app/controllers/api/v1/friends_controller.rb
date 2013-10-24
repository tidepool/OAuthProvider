class Api::V1::FriendsController < Api::V1::ApiController
  doorkeeper_for :all

  def index
    request_for_pending = params[:pending]
    limit = params[:limit].to_i || 20 
    offset = params[:offset].to_i || 0
    raise Api::V1::NotAcceptableError, "Limit cannot be larger than 20." if limit > 20

    user = current_resource
    friends = []
    if request_for_pending && request_for_pending == 'true'
      pending_list = []
      key_types = ['emails', "facebook_ids"]
      key_types.each do |key_type|
        unique_identifier = ""
        case key_type
        when 'emails'
          unique_identifier = user.email
        when 'facebook_ids'
          authentication = user.authentications.where(provider: 'facebook').first
          break if authentication.nil?
          unique_identifier = authentication.uid
        end

        key_name = "pending_#{key_type}:#{unique_identifier}"
        stored_list = $redis.smembers(key_name)        
        stored_list = stored_list.map do | item | 
          { key_type => item }
        end  
        pending_list.concat(stored_list)
      end
      from, to = offset, offset + limit
      email_list = []
      facebook_id_list = []
      pending_list[from..to].each do |item|
        email_list << item["emails"] if item["emails"]
        facebook_id_list << item["facebook_ids"] if item["facebook_ids"]
      end
      authentications = []
      friends = ActiveRecord::Base.connection.execute(User.select(:id, :name, :email, :image).where(email: email_list).to_sql).to_a unless email_list.empty?
      # authentications = Authentication.select(:name, :image).where(uid: facebook_id_list).to_a unless facebook_id_list.empty?
      # friends_with_uids = User.joins(:authentications).select('users.id, users.name, users.email, authentications.uid').where('authentications.uid in (?)', facebook_id_list).to_a unless facebook_id_list.empty?
      friends_with_uids = ActiveRecord::Base.connection.execute(User.joins(:authentications).select('users.id, users.name, users.email, users.image, authentications.uid').where('authentications.uid in (?)', facebook_id_list).to_sql).to_a unless facebook_id_list.empty?
      friends.concat(friends_with_uids)
      api_status = Hashie::Mash.new({
        'offset' => offset,
        'limit' => limit})
      response = {
        data: friends,
        status: api_status
      }
      respond_to do |format|
        format.json { render( json: response.to_json ) }
      end
    else
      friends, api_status = User.paginate(user.friends.select(['users.id', :name, :image]), params)
      respond_to do |format|
        format.json { render({ json: friends, each_serializer: FriendSummarySerializer, meta: api_status }.merge(api_defaults)) }
      end
    end
  end

  def accept
    friend_list = params[:friend_list]
    raise ArgumentError, "No friend list is specified." if friend_list.nil? || friend_list.empty?

    user = current_resource
    raise Api::V1::NotAcceptableError, "User not specified." if user.nil?

    AcceptFriends.perform_async(user.id, user.email, friend_list)
    api_status = Hashie::Mash.new({state: :accepted, message: 'Friend list will be accepted.'})
    respond_to do |format|
      format.json { render({ json: nil, status: :accepted, meta: api_status, serializer: FriendSummarySerializer }.merge(api_defaults) ) }
    end        
  end

  def find
    friend_list = params[:friend_list]
    user = current_resource
    raise Api::V1::NotAcceptableError, "User not specified." if user.nil?
    status_key = "find_status:#{user.id}"
    invite_status = StatusService.check(status_key)
    if invite_status != "pending"
      StatusService.update("find_status:#{user.id}", "pending")
      FindFriends.perform_async(user.id, friend_list) 
      api_status = Hashie::Mash.new({
        state: :pending, 
        link: api_v1_user_friends_progress_url,
        message: "Starting to look for friends for user #{user.email}."
        })
    else
      api_status = Hashie::Mash.new({
        state: :pending,
        message: "Inviting friends is already in progress.",
        link: api_v1_user_friends_progress_url
      })
    end
    respond_to do |format|
      format.json { render({ json: nil, status: :accepted, meta: api_status, serializer: FriendSummarySerializer }.merge(api_defaults) ) }
    end
  end

  def progress 
    user = current_resource
    raise Api::V1::NotAcceptableError, "User not specified." if user.nil?

    status_key = "invite_status:#{user.id}"
    invite_status = StatusService.check(status_key)
    if invite_status == "completed"
      api_status = Hashie::Mash.new({
        state: :done,
        link: api_v1_user_friends_url,
        message: 'Friends list is calculated.'
      })        
    else
      api_status = Hashie::Mash.new({
        state: :pending,
        message: "Inviting friends is already in progress.",
        link: api_v1_user_friends_progress_url
      })
    end
    respond_to do |format|
      format.json { render({ json: nil, status: :ok, meta: api_status, serializer: FriendSummarySerializer, location: api_status.link }.merge(api_defaults)) }
    end
  end

  private
  def current_resource
    target_user
  end
end