require 'spec_helper'

describe NotifyInviter do
  let(:inviter) { create(:user) }
  let(:inviter2) { create(:user) }
  let(:friend) { create(:user, email: "foo@kk.com")}
  let(:invited_user) { create(:invited_user, inviter: inviter, invited_email: "foo@kk.com") }
  let(:invited_user2) { create(:invited_user, inviter: inviter2, invited_email: "foo@kk.com") }

  it 'checks the inviters of a user and makes them friends with the user' do
    invited_user
    NotifyInviter.new.perform(friend.id, friend.email)

    friendship = Friendship.where(user_id: inviter.id, friend_id: friend.id).first
    friendship.should_not be_nil
  end

  it 'does not create friendship if the user is not invited by someone' do 
    NotifyInviter.new.perform(friend.id, friend.email)

    friendship = Friendship.where(user_id: inviter.id, friend_id: friend.id).first
    friendship.should be_nil
  end

  it 'creates friendships to all users who invited the user' do 
    invited_user
    invited_user2

    NotifyInviter.new.perform(friend.id, friend.email)

    friendships = Friendship.where(friend_id: friend.id).to_a
    friendships.should_not be_nil    
    friendships.length.should == 2
  end
end