class FriendsService
  include Paginate

  def find_new_friends(user_id, find_list)
    return if find_list.nil? || find_list.empty? || user_id.nil? 
    found_friends = []
    email_list = find_list[:emails]
    facebook_id_list = find_list[:facebook_ids]
    email_list_length = email_list ? email_list.length : 0
    facebook_list_length = facebook_id_list ? facebook_id_list.length : 0

    raise Api::V1::NotAcceptableError, "Cannot search more than 30 friends at a time." if email_list_length + facebook_list_length  > 30

    found_friends = find_by_email(user_id, email_list)
    found_friends.concat find_by_facebook(user_id, facebook_id_list)
    found_friends
  end

  def invite_friends(user_id, invite_list)
    # ASSUMPTION: 
    # It is expensive to do the rechecks we did in find_new_friends, so we will assume that
    # this list is a list of friends that are already existing TidePool members and they are not user's friends

    invited_user_ids = []
    $redis.multi do 
      invite_list.each do | invited_user |
        invited_user_id = invited_user[:id] || invited_user["id"]
        invited_user_ids << invited_user_id
        $redis.sadd pending_friend_reqs_key(invited_user_id), user_id 
      end
      $redis.sadd invited_friends_key(user_id), invited_user_ids
    end
  end

  def find_pending_friends(user_id, params)
    pending = $redis.smembers pending_friend_reqs_key(user_id)
    total = pending.length
    defaults = {
      limit: 20, 
      offset: 0, 
      total: total
    }

    api_status = FriendsService.generate_status(params, defaults)
    limit = api_status.limit
    offset = api_status.offset

    from = offset < total ? offset : 0 
    to = offset + limit < total ? offset + limit : total
    friend_window = pending[from...to]

    return api_status, User.select(:id, :name, :email, :image).where(id: friend_window).to_a
  end

  def accept_friends(user_id, pending_list)
    pending_list = check_if_in_pending_list(user_id, pending_list)
    return if pending_list.empty?

    friendships = []
    pending_ids_list = []
    pending_list.each do |friend|
      friend_id = friend[:id] || friend["id"]
      pending_ids_list << friend_id
      friendships << Friendship.new(user_id: user_id, friend_id: friend_id)
      friendships << Friendship.new(user_id: friend_id, friend_id: user_id)      
    end
    Friendship.import(friendships)
    remove_from_temp_lists(user_id, pending_ids_list)
  end

  def reject_invitations(user_id, pending_list)
    pending_ids_list = pending_list.map { |friend| friend[:id] || friend["id"] }    
    remove_from_temp_lists(user_id, pending_ids_list)
  end

  def friend_status(caller, target_user)
    status = :not_friend

    fship = Friendship.where(user_id: caller.id, friend_id: target_user.id).first
    $redis.pipelined do 
      @is_pending = $redis.sismember invited_friends_key(caller.id), target_user.id
      @is_invited_by = $redis.sismember pending_friend_reqs_key(caller.id), target_user.id
    end

    is_pending = future_value(@is_pending)
    is_invited_by = future_value(@is_invited_by)
    if fship
      status = :friend
    elsif is_pending
      status = :pending
    elsif is_invited_by
      status = :invited_by
    end
    status
  end

  def unfriend_friends(user_id, friend_list)
    friend_id_list = friend_list.map { |friend| friend[:id] || friend["id"] }
    Friendship.transaction do 
      Friendship.where(user_id: user_id, friend_id: friend_id_list).delete_all
      Friendship.where(user_id: friend_id_list, friend_id: user_id).delete_all
    end
  end

  private
  def find_by_email(user_id, email_list)    
    return [] if email_list.nil? || (email_list && email_list.empty?)

    email_find_query = User.select(:id, :name, :email, :image).where(email: email_list).to_sql
    member_list = ActiveRecord::Base.connection.execute(email_find_query).to_a
    filter_out_existing_friends(user_id, member_list)
  end

  def find_by_facebook(user_id, facebook_id_list)
    return [] if facebook_id_list.nil? || (facebook_id_list && facebook_id_list.empty?)
    fb_find_query = User.joins(:authentications).select('users.id, users.name, users.email, users.image, authentications.uid').where('authentications.uid in (?)', facebook_id_list).to_sql
    member_list = ActiveRecord::Base.connection.execute(fb_find_query).to_a
    filter_out_existing_friends(user_id, member_list)
  end

  def filter_out_existing_friends(user_id, member_list)
    filtered_list = []
    member_ids = member_list.map { |member| member[:id] || member["id"] }
    existing_friends = Friendship.where(user_id: user_id, friend_id: member_ids).to_a
    member_list.each do |member|
      member_id = member[:id] || member["id"]
      existing_friend = nil
      existing_friend = existing_friends.find_all { |friend| friend.friend_id.to_i == member_id.to_i }
      filtered_list << member if existing_friend.empty? && (member_id.to_i != user_id.to_i)
    end
    filtered_list
  end

  def check_if_in_pending_list(user_id, pending_list)
    @is_member = []
    $redis.pipelined do 
      pending_list.each do |friend| 
        friend_id = friend[:id] || friend["id"]
        @is_member << $redis.sismember(pending_friend_reqs_key(user_id), friend_id) 
      end
    end
    new_list = []
    pending_list.each_with_index do |friend, i| 
      is_member = future_value(@is_member[i])
      new_list << friend if is_member
    end
    new_list
  end

  def future_value(input)
    while input.value.is_a?(Redis::FutureNotReady)
      sleep(1.0 / 100.0)
    end
    input.value
  end

  # friend_list is an array of ids
  def remove_from_temp_lists(user_id, friend_list)
    $redis.multi do 
      remove_from_pending_list(user_id, friend_list)
      remove_from_invited_user_lists(user_id, friend_list)
    end
  end

  # friend_list is an array of ids
  def remove_from_pending_list(user_id, friend_list)
    $redis.srem pending_friend_reqs_key(user_id), friend_list
  end

  # friend_list is an array of ids
  def remove_from_invited_user_lists(user_id, friend_list)
    friend_list.each do |friend_id|
      $redis.srem invited_friends_key(friend_id), user_id
    end
  end

  # List of pending friend requests from other users for the user_id
  def pending_friend_reqs_key(user_id)
    "pending_friend_reqs:#{user_id}"
  end

  # List of friends user_id has invited but not accepted yet.
  def invited_friends_key(user_id)
    "invited_friends:#{user_id}"
  end
end
