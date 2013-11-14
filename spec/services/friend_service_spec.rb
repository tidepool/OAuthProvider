require 'spec_helper'

describe FriendsService do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:friend_list) { create_list(:friend_user, 7)}
  # let(:friend_auth_list) { create_list(:friend_authentications, 8)}
  # let(:friendships) { create_list(:friendship, 10, user: user1)}

  describe "Friend status for a caller and target user" do 
    before :each do
      @friend_service = FriendsService.new      
    end
    
    it 'returns the user status as friend if the user is a friend of the caller' do 
      # User 1 invites a whole bunch of friends
      invite_list = friend_list.map { |friend| { id: friend.id } }
      @friend_service.invite_friends(user1.id, invite_list)

      # friend_list[0] accepts user1 
      pending_list = [{id: user1.id}]
      @friend_service.accept_friends(friend_list[0].id, pending_list)

      friendship = Friendship.where(user_id: user1.id, friend_id: friend_list[0].id).first
      friendship.should_not be_nil

      is_member = $redis.sismember "friends:#{user1.id}", friend_list[0].id
      is_member.should_not be_false

      status = @friend_service.friend_status(user1, friend_list[0])
      status.should == :friend
    end

    it 'returns the user status as not friend if the user is not a friend of the caller' do 
      status = @friend_service.friend_status(user1, user2)
      status.should == :not_friend
    end

    it 'returns the user status as pending if the user is invited by the caller' do 
      invite_list = friend_list.map { |friend| { id: friend.id } }
      @friend_service.invite_friends(user1.id, invite_list)

      status = @friend_service.friend_status(user1, friend_list[0])
      status.should == :pending
    end

    it 'returns the user status as invited_by if the caller is invited by the user' do 
      invite_list = [{id: user1.id}]
      @friend_service.invite_friends(friend_list[0].id, invite_list)

      status = @friend_service.friend_status(user1, friend_list[0])
      status.should == :invited_by
    end
  end
end