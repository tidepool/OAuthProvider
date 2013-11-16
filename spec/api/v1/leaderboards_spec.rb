require 'spec_helper'

describe 'Leaderboards API' do 
  include AppConnections
  include FriendHelpers

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:user1) { create(:friend_user) }
  let(:user_list) { create_list(:friend_user, 20)}

  describe 'Global Leaderboard' do 
    before :each do 
      rand_gen = Random.new
      sample_scores = user_list.map do |user| 
        [rand_gen.rand(100.0..1000.0), user.id]
      end
      $redis.zadd "global_lb:fizzbuzz", sample_scores
    end

    it 'retrieves the global leaderboard' do 
      token = get_conn(user1)
      response = token.get("#{@endpoint}/games/fizzbuzz/leaderboard.json?limit=5&offset=0")
      result = JSON.parse(response.body, symbolize_names: true)
      user_info = result[:data]
      user_info.length.should == 5
      user_info[0][:name].scan(/Mary/).should == ["Mary"]
      user_info[0][:email].scan(/example/).should == ["example"]
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
  end

  describe 'Friends Leaderboard' do 
    before :each do 
      rand_gen = Random.new
      sample_scores = user_list.map do |user| 
        [rand_gen.rand(100.0..1000.0), user.id]
      end
      $redis.zadd "global_lb:fizzbuzz", sample_scores

      create_friends(user1, user_list[0..6])
      # friend_list = user_list[0..6].map { |user| user.id }
      # $redis.sadd "friends:#{user1.id}", friend_list
    end

    it 'retrieves the friend leaderboard' do 
      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/games/fizzbuzz/leaderboard.json?limit=4&offset=0")
      result = JSON.parse(response.body, symbolize_names: true)
      user_info = result[:data]
      user_info.length.should == 4
      user_info[0][:name].scan(/Mary/).should == ['Mary']
      user_info[0][:email].scan(/example/).should == ["example"]
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