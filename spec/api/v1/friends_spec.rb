require 'spec_helper'

describe 'Friends API' do 
  include AppConnections

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:user1) { create(:user) }
  let(:authentication) { create(:authentication, user: user1) }

  describe 'Getting a list of friends' do 
    let(:friend_list) { create_list(:user, 7)}
    let(:friend_auth_list) { create_list(:friend_authentications, 8)}
    let(:friendships) { create_list(:friendship, 10, user: user1)}

    before :each do 
      pending_friend_emails = (0..6).map {|i| friend_list[i].email }
      key = "pending_emails:#{user1.email}"
      $redis.sadd(key, pending_friend_emails)
      pending_friend_uids = (0..7).map {|i| friend_auth_list[i].uid }
      key = "pending_facebook_ids:#{authentication.uid}"
      $redis.sadd(key, pending_friend_uids)
    end

    it 'a list of pending friends with paging' do
      authentication 
      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/friends.json?pending=true&limit=20&offset=5")
      result = JSON.parse(response.body, symbolize_names: true)
      user_info = result[:data]

      user_info.length.should == (7 + 8 - 5)
      user_info[0][:name].scan(/Mary/).should == ["Mary"]
      user_info[0][:image].scan(/image/).should == ["image"]
      user_info[0][:email].should_not be_nil
      user_info[0][:id].should_not be_nil
      user_info[9][:uid].should_not be_nil
      user_info[9][:image].should_not be_nil
      status = result[:status]      
      status[:offset].should == 5
      status[:limit].should == 20
    end

    it 'a list of existing friends' do 
      friendships
      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/friends.json?limit=5&offset=0")
      result = JSON.parse(response.body, symbolize_names: true)
      user_info = result[:data]
      user_info.length.should == 5
      user_info[0][:name].scan(/Mary/).should == ["Mary"]
      user_info[0][:image].scan(/image/).should == ["image"]
      status = result[:status]      
      status[:offset].should == 0
      status[:limit].should == 5
    end
  end

  describe 'Finding a list of friends' do 
    let(:friend_list) { create_list(:user, 7)}
    let(:friend_auth_list) { create_list(:authentication, 8)}

    before :each do
      FindFriends.stub(:perform_async) do |user_id, friend_list|
        FindFriends.new.perform(user_id, friend_list)
      end
      friend_list
      friend_auth_list
      AddAllUsersToRedis.new.perform
    end

    it 'finds the already existing members from a list of emails and adds the user_id as a pending friend' do 
      params = { friend_list: {} } 
      params[:friend_list][:emails] = friend_list.map { | item | item.email }

      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/friends/find.json", {body: params})
      result = JSON.parse(response.body, symbolize_names: true)
      friend_list.each do |friend|
        key_name = "pending_emails:#{friend.email}"
        member = $redis.smembers(key_name)      
        member[0].to_i.should == user1.id
      end
    end

    it 'does not add the user as a pending friend if they are already friends' do 
      params = { friend_list: {} } 
      params[:friend_list][:emails] = friend_list.map { | item | item.email }

      # Add the first friend in the friend_list as an already existing friend for user1
      look_up_key = "friend_list_emails:#{user1.id}"
      $redis.sadd(look_up_key, friend_list[0].email)      
      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/friends/find.json", { body: params })
      response.status.should == 202    
      key_name = "pending_emails:#{friend_list[0].email}"
      member = $redis.smembers(key_name) 
      member.should be_empty
      key_name = "pending_emails:#{friend_list[1].email}"
      member = $redis.smembers(key_name) 
      member[0].to_i.should == user1.id
    end
  end

  describe 'Accepting a set of friends' do 
    let(:friend_list) { create_list(:user, 10)}
    let(:friend_auth_list) { create_list(:authentication, 10)}

    before :each do
      AcceptFriends.stub(:perform_async) do |user_id, user_email, friend_list|
        AcceptFriends.new.perform(user_id, user_email, friend_list)
      end
      friend_list
      friend_auth_list
      AddAllUsersToRedis.new.perform
    
      pending_friend_ids = (0..5).map {|i| friend_list[i].id }
      key = "pending_emails:#{user1.email}"
      $redis.sadd(key, pending_friend_ids)
      pending_friend_ids = (0..5).map {|i| friend_auth_list[i].user_id }
      key = "pending_facebook_ids:#{authentication.uid}"
      $redis.sadd(key, pending_friend_ids)
    end

    it 'accepts the friends with emails' do 
      # Get the first 3 friends from the friend_list and and accept them
      to_be_accepted = (0..2).map do |i| 
        { 
          id: friend_list[i].id,
          email: friend_list[i].email
        }
      end

      params = { friend_list: to_be_accepted }
      token = get_conn(user1)
      response = token.post("#{@endpoint}/users/-/friends/accept.json", { body: params })
      response.status.should == 202
      friends_in_redis = $redis.smembers("friend_list_emails:#{user1.id}")
      friends_in_redis.length.should == 3
      pending_emails = $redis.smembers("pending_emails:#{user1.email}")
      pending_emails.length.should == 6 - 3
      user1.friends.length.should == 3
      user1.friends[0].friends.length.should == 1
      user1.friends[0].friends[0].email.should == user1.email
    end


  end
end
