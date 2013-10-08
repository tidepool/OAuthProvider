require 'spec_helper'

describe InviteFriends do
  let(:user1) { create(:user) }
  let(:invitation) { create(:invitation, user: user1)}

  before :each do 
    @friend_list = ["foo@kk.com", "bar@kk.com", "foobar@kk.com"]
    InviteFriend.stub(:perform_async) do |user_id, email, status|
      # Do nothing
      Rails.logger.info("InviteFriend for user #{user_id}, friend #{email} with status #{status} called.")
    end 
  end

  it 'sends email to a friend_list' do
    InviteFriends.new.perform(user1.id, @friend_list)

    invitation = Invitation.where(user_id: user1.id).first
    invite_list = invitation.email_invite_list

    invite_list.should_not be_nil
    @friend_list.each do |email|
      invite_list[email].should == 'sent'
    end
  end

  it 'sends email to friend_list where there were already pre-existing invitations' do 
    invitation
    InviteFriends.new.perform(user1.id, @friend_list)

    invitation = Invitation.where(user_id: user1.id).first
    invite_list = invitation.email_invite_list

    invite_list.should_not be_nil
    @friend_list.each do |email|
      invite_list[email].should == 'sent'
    end
  end
end