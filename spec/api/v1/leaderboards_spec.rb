require 'spec_helper'

describe 'Leaderboards API' do 
  include AppConnections
  include FriendHelpers

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  def add_to_global_lb(users)
    rand_gen = Random.new
    sample_scores = users.map do |user| 
      [rand_gen.rand(100.0..1000.0), user.id]
    end
    $redis.zadd "global_lb:fizzbuzz", sample_scores
  end

  let(:user1) { create(:friend_user) }
  let(:user_list) { create_list(:friend_user, 20)}
  let(:user_list_no_name) { create_list(:friend_user_no_name, 20)}

  describe 'Global Leaderboard' do 
    it 'retrieves the global leaderboard' do 
      add_to_global_lb(user_list)

      token = get_conn(user1)
      response = token.get("#{@endpoint}/games/fizzbuzz/leaderboard.json?limit=5&offset=0")
      result = JSON.parse(response.body, symbolize_names: true)
      user_info = result[:data]
      user_info.length.should == 5
      user_info[0][:name].scan(/Mary/).should == ["Mary"]
      user_info[0][:image].scan(/image/).should == ["image"]

      ascending = user_info[0][:score] - user_info[1][:score]
      ascending.should > 0
      
      status = result[:status]
      status.should == {
        :offset => 0,
        :limit => 5,
        :next_offset => 5,
        :next_limit => 5,
        :total => 20
      } 
    end

    it 'retrieves the first part of emails of a user if name does not exist' do 
      add_to_global_lb(user_list_no_name)
      token = get_conn(user1)
      response = token.get("#{@endpoint}/games/fizzbuzz/leaderboard.json?limit=5&offset=0")
      result = JSON.parse(response.body, symbolize_names: true)
      user_info = result[:data]
      user_info.length.should == 5
      user_info[0][:name].scan(/spec_user/).should == ["spec_user"]
    end
  end

  describe 'Friends Leaderboard' do 
    before :each do 
      add_to_global_lb(user_list)
      create_friends(user1, user_list[0..6])
    end

    it 'retrieves the friend leaderboard' do 
      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/games/fizzbuzz/leaderboard.json?limit=4&offset=0")
      result = JSON.parse(response.body, symbolize_names: true)
      user_info = result[:data]
      user_info.length.should == 4
      user_info[0][:name].scan(/Mary/).should == ['Mary']
      user_info[0][:image].scan(/image/).should == ["image"]

      ascending = user_info[0][:score] - user_info[1][:score]
      ascending.should > 0

      status = result[:status]
      status.should == {
             :offset => 0,
              :limit => 4,
        :next_offset => 4,
         :next_limit => 3,
              :total => 7
      }
    end
  end
end