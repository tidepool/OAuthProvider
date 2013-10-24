class AcceptFriends
  include Sidekiq::Worker
  sidekiq_options :retry => 5, :backtrace => 5

  # friend_list 
  # [ {
  #   id: 12,
  #   email: "foo@foo.com",
  #   uid: "12345" },...]
  def perform(user_id, user_email, friend_list)
    return if friend_list.nil? || friend_list.empty?

    # TODO: I should check if these friends are invited in the first place
    # Check the pending bucket in redis

    authentication = Authentication.where(user_id: user_id, provider: 'facebook').first
    user_uid = nil
    user_uid = authentication.uid if authentication

    add_to_friend_lists(user_id, user_email, user_uid, friend_list)

    add_friendship_records(user_id, friend_list)

    remove_from_pending_lists(user_id, user_email, user_uid, friend_list)    
  end

  def add_to_friend_lists(user_id, user_email, user_uid, friend_list)
    # Add to the user's Redis friend_list_* key
    # For the friend_list_emails
    emails = friend_list.map { |friend| friend["email"] || friend[:email] }
    $redis.sadd("friend_list_emails:#{user_id}", emails)

    # For the friend_list_facebook_ids
    facebook_ids = friend_list.map { |friend| friend["uid"] || friend[:uid] }
    $redis.sadd("friend_list_facebook_ids:#{user_id}", facebook_ids)

    # Add the user to each friend's Redis friend_list_* key
    $redis.pipelined do 
      friend_list.each do |friend|
        friend_id = friend[:id] || friend["id"]
        $redis.sadd("friend_list_facebook_ids:#{friend_id}", user_uid) if user_uid
        $redis.sadd("friend_list_emails:#{friend_id}", user_email) if user_email
      end
    end
  end

  def add_friendship_records(user_id, friend_list)
    friendships = []
    friend_list.each do |friend|
      friend_id = friend[:id] || friend["id"]
      friendships << Friendship.new(user_id: user_id, friend_id: friend_id)
      friendships << Friendship.new(user_id: friend_id, friend_id: user_id)      
    end
    Friendship.import(friendships)
  end

  def remove_from_pending_lists(user_id, user_email, user_uid, friend_list)
    # The user can have 2 buckets of pending invitations in Redis
    # 1. pending_emails
    # 2. pending_facebook_ids
    # remove from both

    friend_ids = friend_list.map { |friend| friend[:id] || friend["id"] }
    $redis.srem "pending_emails:#{user_email}", friend_ids
    $redis.srem "pending_facebook_ids:#{user_uid}", friend_ids if user_uid
  end
end