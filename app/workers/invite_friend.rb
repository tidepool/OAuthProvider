class InviteFriend
  include Sidekiq::Worker
  sidekiq_options :retry => 5, :backtrace => 5

  def perform(user_id, friend_email, status)
    friend = check_user(friend_email)
    if friend
      add_user_as_friend(user_id, friend)
    else
      unless status == 'sent'   
        add_user_to_invited_user(user_id, friend_email)
        invite_user(user_id, friend_email)    
      end
    end
  end

  private
  def check_user(email)
    user = User.where(email: email).first
  end

  def invite_user(user_id, email)
    UserMailer.friend_invite_email({user_id: user_id, friend_email: email}).deliver
  end

  def add_user_as_friend(user_id, friend)
    friendship = Friendship.where(user_id: user_id, friend_id: friend.id).first_or_initialize   
    friendship.save! 
  end

  def add_user_to_invited_user(user_id, email)
    invited_user = InvitedUser.where(inviter_id: user_id, invited_email: email).first_or_initialize
    invited_user.save!
  end
end