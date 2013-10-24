class AcceptFriendInvitation
  include Sidekiq::Worker
  sidekiq_options :retry => 5, :backtrace => 5

  def perform(user_email, user_id, authentication_uid = nil)
    buckets = ['emails', 'facebook_ids']
    buckets.each do | bucket |
      identifier = ""
      if bucket == 'facebook_ids'
        break if authentication_uid.nil?
        identifier = authentication_uid
      else 
        identifier = user_email
      end

      key_name = "invited_#{bucket}:#{identifier}"
      friends_invited_user = $redis.smembers(key_name)
      friends_invited_user.each do |friend_identifier|
        friend = nil
        case bucket 
        when 'emails'
          friend = User.where(email: friend_identifier).first
        when 'facebook_ids' 
          friend_authentication = Authentication.where(uid: friend_identifier).first
          friend = friend_authentication.user if friend_authentication
        end
        friendship = Friendship.where(user_id: user_id, friend_id: friend.id).first_or_create
        reverse_friendship = Friendship.where(user_id: friend.id, friend_id: user_id).first_or_create
      end

      $redis.srem(key_name)      
    end
  end
end