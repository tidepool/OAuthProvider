class InviteFriends
  include Sidekiq::Worker
  sidekiq_options :retry => 5, :backtrace => 5

  def perform(user_id, friend_list)
    return if friend_list.nil? || friend_list.empty?
    invitation = Invitation.where(user_id: user_id).first_or_initialize
    invite_list = invitation.email_invite_list || {}

    friend_list.each do | email |
      status = invite_list[email] || 'not_sent'
      InviteFriend.perform_async(user_id, email, status)
      invite_list[email] = 'sent'
    end
    invitation.email_invite_list = invite_list
    invitation.save!
  end
end