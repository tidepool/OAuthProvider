require 'spec_helper'

describe 'Friends API' do 
  include AppConnections
  include FriendHelpers

  # def create_friends
  #   invite_list = friend_list.map { |friend| { id: friend.id} }
  #   friend_service = FriendsService.new
  #   friend_service.invite_friends(user1.id, invite_list)
  #   invite_list.each do |friend|
  #     friend_service.accept_friends(friend[:id], [{ id: user1.id }] )
  #   end
  # end

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:user1) { create(:friend_user) }
  let(:authentication) { create(:authentication, user: user1) }

  describe 'Friendlist and unfriending' do 
    let(:friend_list) { create_list(:friend_user, 7)}
    let(:friend_auth_list) { create_list(:friend_authentications, 8)}

    before :each do 
      create_friends(user1, friend_list)
    end

    it 'a list of existing friends' do 
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
      status[:next_offset].should == 5
      status[:next_limit].should == 2
      status[:total].should == 7
    end

    it 'unfriends a list of friends' do 
      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/friends.json?limit=5&offset=0")
      result = JSON.parse(response.body, symbolize_names: true)
      existing_friends = result[:data]

      # My friends in Postgres
      user1.friends.length.should == 7

      # Friends friends in Postgres
      user1.friends.each do |friend| 
        friend.friends.length.should == 1
      end

      params = {friend_list: existing_friends}
      response = token.post("#{@endpoint}/users/-/friends/unfriend.json", { body: params})
      result = JSON.parse(response.body, symbolize_names: true)
      user_info = result[:data]
      new_user = User.find(user1.id)

      # My friends in Postgres
      new_user.friends.length.should == 2

      # Friends friends in Postgres
      existing_friends.each do |existing_friend| 
        old_friend = User.find(existing_friend[:id])
        old_friend.friends.length.should == 0
      end

      status = result[:status]
      status[:message].should == 'Friend list unfriended.'
    end
  end

  describe 'Pending and accepting or rejecting' do 
    let(:friend_list) { create_list(:friend_user, 7)}

    before :each do
      key_name = "pending_friend_reqs:#{user1.id}"
      pending_friends = friend_list[0..3].map { |friend| friend.id }
      $redis.sadd(key_name, pending_friends)
    end

    it 'gets a list of all pending friends' do 
      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/friends/pending.json?offset=1&limit=2")
      result = JSON.parse(response.body, symbolize_names: true)
      user_info = result[:data]
      user_info.length.should == 2
      pending = $redis.smembers "pending_friend_reqs:#{user1.id}"

      status = result[:status] 
      status[:offset].should == 1
      status[:limit].should == 2
      status[:next_offset].should == 3
      status[:next_limit].should == 1
      status[:total].should == 4
    end

    it 'accepts the list of pending friends as friends' do 
      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/friends/pending.json")
      result = JSON.parse(response.body, symbolize_names: true)
      pending_friends = result[:data]
      params = {friend_list: pending_friends}
      response = token.post("#{@endpoint}/users/-/friends/accept.json", { body: params})
      result = JSON.parse(response.body, symbolize_names: true)

      pending = $redis.smembers "pending_friend_reqs:#{user1.id}"  
      pending.length.should == 0
      user1.friends.length.should == 4

      status = result[:status]
      status[:message].should == 'Friend list accepted.'
    end

    it 'does not accept the pending friends input if they are not actually on pending friends lists' do 
      # Make up a list of friends who are not pending and some pending
      pending_friends = friend_list[0..6].map { |friend| {id: friend.id } }
      params = {friend_list: pending_friends}
      token = get_conn(user1)
      response = token.post("#{@endpoint}/users/-/friends/accept.json", { body: params})
      result = JSON.parse(response.body, symbolize_names: true)

      user1.friends.length.should == 4
    end

    it 'rejects friend invitations' do 
      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/friends/pending.json")
      result = JSON.parse(response.body, symbolize_names: true)

      pending = $redis.smembers "pending_friend_reqs:#{user1.id}"  
      pending.length.should_not == 0

      pending_friends = result[:data]
      params = {friend_list: pending_friends}
      response = token.post("#{@endpoint}/users/-/friends/reject.json", { body: params})
      result = JSON.parse(response.body, symbolize_names: true)

      pending = $redis.smembers "pending_friend_reqs:#{user1.id}"  
      pending.length.should == 0
      user1.friends.length.should == 0

      status = result[:status]
      status[:message].should == 'Friend list rejected.'

    end
  end

  describe 'Finding and inviting' do 
    let(:friend_list) { create_list(:friend_user, 10)}
    let(:cur_friend_list) { create_list(:friend_user, 5)}
    let(:friend_auth_list) { create_list(:friend_authentications, 10)}

    it 'finds a list of friends from emails' do 
      friend_list
      find_list = friend_list[0..3].map { |friend| friend.email } 
      find_list << "foo@foo.com"  # A non-existing friend
 
      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/friends/find.json", :params => {'email' => find_list })
      result = JSON.parse(response.body, symbolize_names: true)
      found_friends = result[:data]
      found_friends.length.should == 4
      found_list = found_friends.find_all { |friend| friend[:email] == "foo@foo.com" }
      found_list.should be_empty

      found_list = found_friends.find_all { |friend| friend[:email] == friend_list[0].email }
      found_list.should_not be_empty
    end

    it 'finds a list of friends, except your already existing friends' do 
      friend_list
      create_friends(user1, cur_friend_list)
      friend_email = user1.friends[0].email
      find_list = friend_list[0..3].map { |friend| friend.email } 
      find_list << friend_email # Your existing friend
      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/friends/find.json", :params => {'email' => find_list })
      result = JSON.parse(response.body, symbolize_names: true)
      found_friends = result[:data]
      found_friends.length.should == 4
      found_list = found_friends.find_all { |friend| friend[:email] == friend_email }
      found_list.should be_empty
    end

    it 'finds a list of friends, except yourself, if your email is included accidentally' do
      friend_list
      find_list = friend_list[0..3].map { |friend| friend.email } 
      find_list << user1.email

      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/friends/find.json", :params => {'email' => find_list })
      result = JSON.parse(response.body, symbolize_names: true)
      found_friends = result[:data]
      found_friends.length.should == 4
      found_list = found_friends.find_all { |friend| friend[:email] == user1.email }
      found_list.should be_empty

      found_list = found_friends.find_all { |friend| friend[:email] == friend_list[0].email }
      found_list.should_not be_empty
    end

    it 'finds a list of friends from facebook ids' do 
      friend_auth_list
      find_list = friend_auth_list[0..3].map { |friend| friend.uid } 
      params = {friend_list: { facebook_ids: find_list} }
      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/friends/find.json", :params => {'fbid' => find_list })
      result = JSON.parse(response.body, symbolize_names: true)
      found_friends = result[:data]
      found_friends.length.should == 4
      found_list = found_friends.find_all { |friend| friend[:uid] == friend_auth_list[0].uid }
      found_list.should_not be_empty
    end

    it 'finds a list of friends some from emails, some facebook_ids' do
      friend_list
      friend_auth_list
      email_list = friend_list[0..5].map { |friend| friend.email } 
      uid_list = friend_auth_list[0..3].map { |friend| friend.uid }

      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/friends/find.json",:params => {'email' => email_list, 'fbid' => uid_list})
      result = JSON.parse(response.body, symbolize_names: true)
      found_friends = result[:data]
      found_friends.length.should == 10
      found_list = found_friends.find_all { |friend| friend[:uid] == friend_auth_list[0].uid }
      found_list.should_not be_empty

      found_list = found_friends.find_all { |friend| friend[:email] == friend_list[0].email }
      found_list.should_not be_empty
    end

    it 'invites found friends' do 
      friend_list
      find_list = friend_list[0..3].map { |friend| friend.email } 
      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/friends/find.json", :params => {'email' => find_list })
      result = JSON.parse(response.body, symbolize_names: true)
      found_friends = result[:data]

      params = {friend_list: found_friends}
      response = token.post("#{@endpoint}/users/-/friends/invite.json", { body: params})
      result = JSON.parse(response.body, symbolize_names: true)
      invite_list = $redis.smembers "pending_friend_reqs:#{friend_list[0].id}"
      invite_list.should_not be_empty
      invite_list[0].to_i.should == user1.id

      status = result[:status]
      status[:message].should == 'Friend list invited, once they accept they will be your friends.'

    end
  end

end
