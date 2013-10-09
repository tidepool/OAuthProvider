class NotifyInviter
  include Sidekiq::Worker
  sidekiq_options :retry => 5, :backtrace => 5

  def perform(friend_id, friend_email)
    inviters = InvitedUser.where(invited_email: friend_email).to_a
    inviters.each do |inviter|
      friendship = Friendship.where(user_id: inviter.inviter_id, friend_id: friend_id).first_or_initialize   
      friendship.save! 
    end
  end
end