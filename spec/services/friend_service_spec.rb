require 'spec_helper'

describe FriendsService do
  include FriendHelpers

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:friend_list) { create_list(:friend_user, 7)}

  describe "Friend status for a caller and target user" do 
    before :each do
      @friend_service = FriendsService.new      
    end
    
    it 'returns the user status as friend if the user is a friend of the caller' do 
      make_friends(user1, user2)

      friendship = Friendship.where(user_id: user1.id, friend_id: user2.id).first
      friendship.should_not be_nil

      status = @friend_service.friend_status(user1, user2)
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

  describe "Sending emails for invites and accepts" do 
    before :each do
      MailSender.stub(:perform_async) do |mailer_klass_name, mailer_method, options|
        MailSender.new.perform(mailer_klass_name, mailer_method, options)
      end
      @friend_service = FriendsService.new    
    end

    it 'sends email to the friends when they are invited by a user' do 
      invited_friends = []
      FriendMailer.any_instance.stub(:friend_request_email) do |options|
        user_id = options[:user_id] || options["user_id"]
        friend_id = options[:friend_id] || options["friend_id"]
        user, friend = User.where(id: [user_id, friend_id]).to_a

        user.should_not be_nil
        friend.should_not be_nil
        friend.id.should == user1.id
        invited_friends << friend
      end

      invite_list = friend_list.map { |friend| { id: friend.id } }
      @friend_service.invite_friends(user1.id, invite_list)
      invited_friends.length.should == friend_list.length
    end

    it 'sends email to the user when their friend request is accepted' do 
      accepted_friends = []
      FriendMailer.any_instance.stub(:friend_accept_email) do |options|
        user_id = options[:user_id] || options["user_id"]
        friend_id = options[:friend_id] || options["friend_id"]
        user, friend = User.where(id: [user_id, friend_id]).to_a
        user.should_not be_nil
        user.id.should == user1.id
        friend.should_not be_nil
        accepted_friends << friend
      end

      create_friends(user1, friend_list)
      accepted_friends.length.should == friend_list.length  
    end

  end
end