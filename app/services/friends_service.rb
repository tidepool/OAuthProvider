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

  def invite_friends(user_id, invite_list)
    # ASSUMPTION: 
    # It is expensive to do the rechecks we did in find_new_friends, so we will assume that
    # this list is a list of friends that are already existing TidePool members and they are not user's friends

    $redis.pipelined do 
      invite_list.each do | invited_user |
        invited_user_id = invited_user[:id] || invited_user["id"]
        key_name = "pending_friend_reqs:#{invited_user_id}"
        $redis.sadd(key_name, user_id)
      end
    end
  end

  def find_pending_friends(user_id, params)
    key_name = "pending_friend_reqs:#{user_id}"
    pending = $redis.smembers(key_name)
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
    friendships = []
    pending_list.each do |friend|
      friend_id = friend[:id] || friend["id"]
      friendships << Friendship.new(user_id: user_id, friend_id: friend_id)
      friendships << Friendship.new(user_id: friend_id, friend_id: user_id)      
    end
    Friendship.import(friendships)

    add_friends_to_redis(user_id, pending_list)
    remove_from_pending_lists(user_id, pending_list)
  end

  def add_friends_to_redis(user_id, pending_list)
    friend_list = []
    $redis.pipelined do 
      pending_list.each do |friend| 
        friend_id = friend[:id] || friend["id"]
        friend_list << friend_id
        $redis.sadd "friends:#{friend_id}", user_id
      end
    end
    $redis.sadd "friends:#{user_id}", friend_list
  end

  def remove_from_pending_lists(user_id, friend_list)
    friend_ids = friend_list.map { |friend| friend[:id] || friend["id"] }
    $redis.srem "pending_friend_reqs:#{user_id}", friend_ids
  end
end
