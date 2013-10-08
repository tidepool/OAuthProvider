require 'spec_helper'

class FakeMailer
  def deliver
  end
end

describe InviteFriend do
  let(:user) { create(:user) }
  let(:friend1) { create(:user, email: "foo@kk.com") }

  before :each do 
  end  

  it 'adds an existing user as a friend' do 
    InviteFriend.new.perform(user.id, friend1.email, 'not_sent')

    friendship = Friendship.where(user_id: user.id, friend_id: friend1.id).first
    friendship.should_not be_nil

    updated_user = User.find(user.id)
    updated_user.friends.length.should == 1
    updated_user.friends[0].email.should == friend1.email   
  end

  it 'invites a user if not invited yet' do
    email = "bar@kk.com"
    UserMailer.stub(:friend_invite_email) do |options|
      options[:user_id].should == user.id
      options[:friend_email].should == email
      FakeMailer.new
    end

    InviteFriend.new.perform(user.id, email, 'not_sent')
  end

  it 'does not invite the user if already invited' do 
    email = "bar@kk.com"
    UserMailer.stub(:friend_invite_email) do |options|
      # Will raise an undefined method error if called, so it should not be called!
    end

    InviteFriend.new.perform(user.id, email, 'sent')
  end
end