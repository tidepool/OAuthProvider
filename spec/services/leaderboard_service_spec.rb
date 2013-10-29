require 'spec_helper'

describe LeaderboardService do
  let(:user1) { create(:user) }

  describe "Global Leaderboard" do 
    let(:user_list) { create_list(:friend_user, 20)}
    before :each do 
      rand_gen = Random.new
      sample_scores = user_list.map do |user| 
        [rand_gen.rand(100.0..1000.0), user.id]
      end
      $redis.zadd "global_lb:fizzbuzz", sample_scores
    end

    it 'add friends to the global leaderboard' do 
      lb_service = LeaderboardService.new('fizzbuzz', user1.id)
      api_status, leaders = lb_service.global_leaderboard
      api_status.should == {
             "offset" => 0,
              "limit" => 10,
        "next_offset" => 10,
         "next_limit" => 10,
              "total" => 20
      }
      leaders.length.should == 10
      ascending = leaders[0][:score] - leaders[1][:score]
      ascending.should > 0
    end

    it 'adds a new entry to the global leaderboard' do 
      lb_service = LeaderboardService.new('fizzbuzz', user1.id)
      lb_service.update_global_leaderboard(1000.0)
      entry = Leaderboard.where(game_name: 'fizzbuzz', user_id: user1.id).first
      entry.score.should == 1000.0
      entry = $redis.zrevrange "global_lb:fizzbuzz", 0, 1, with_scores: true
      entry[0][1].should == 1000.0
      entry[0][0].should == user1.id.to_s
    end

    it 'updates the global leaderboard only if the score is higher' do 
      lb_service = LeaderboardService.new('fizzbuzz', user1.id)
      lb_service.update_global_leaderboard(1000.0)

      # Update with smaller score
      lb_service = LeaderboardService.new('fizzbuzz', user1.id)
      lb_service.update_global_leaderboard(900.0)

      entry = Leaderboard.where(game_name: 'fizzbuzz', user_id: user1.id).first
      entry.score.should == 1000.0
      entry = $redis.zscore "global_lb:fizzbuzz", user1.id.to_s
      entry.should == 1000.0
    end

    it 'updates an individuals score with a higher score' do 
      lb_service = LeaderboardService.new('fizzbuzz', user1.id)
      lb_service.update_global_leaderboard(1000.0)

      # Update with higher score
      lb_service = LeaderboardService.new('fizzbuzz', user1.id)
      lb_service.update_global_leaderboard(1200.0)

      entry = Leaderboard.where(game_name: 'fizzbuzz', user_id: user1.id).first
      entry.score.should == 1200.0
      entry = $redis.zscore "global_lb:fizzbuzz", user1.id.to_s
      entry.should == 1200.0      
    end
  end

  describe "Friends Leaderboard" do 
    let(:user_list) { create_list(:friend_user, 20)}
    before :each do 
      rand_gen = Random.new
      sample_scores = user_list.map do |user| 
        [rand_gen.rand(100.0..1000.0), user.id]
      end
      $redis.zadd "global_lb:fizzbuzz", sample_scores

      friend_list = user_list[0..3].map { |user| user.id }
      $redis.sadd "friends:#{user1.id}", friend_list
    end

    it 'reads from the friend leaderboard for the first time' do 
      lb_service = LeaderboardService.new('fizzbuzz', user1.id)
      lb_service.update_global_leaderboard(1000.0)

      api_status, results = lb_service.friends_leaderboard
      api_status.should == {
        "offset" => 0,
        "limit" => 10,
        "next_offset" => 0,
        "next_limit" => 10,
        "total" => 5
      }

      results.length.should == 5
      ascending = results[0][:score] - results[1][:score]
      ascending.should > 0
      
      # Contains friends scores
      friends = $redis.smembers "friends:#{user1.id}"
      friends.each do | friend_id |
        found = results.find_all { |result| friend_id.to_s == result[:id].to_s }
        found.should_not be_empty
        found.length.should == 1
      end

      # Contains my score
      found = results.find_all { |result| user1.id.to_s == result[:id].to_s }
      found.should_not be_empty
      found.length.should == 1

      # Updated the last_accessed_time
      last_accessed = $redis.get "friend_lb:fizzbuzz:#{user1.id}:last"
      last_accessed.should_not be_nil
    end

    it 'reads from the friend leaderboard in consecutive times, no caching' do 
      lb_service = LeaderboardService.new('fizzbuzz', user1.id, 0)
      lb_service.update_global_leaderboard(900.0)

      api_status, results = lb_service.friends_leaderboard
      results.length.should == 5
      found = results.find_all { |result| user1.id.to_s == result[:id].to_s }
      found[0][:score].should == 900.0
 
      # A new high score
      lb_service.update_global_leaderboard(1000.0)
      api_status, results = lb_service.friends_leaderboard
      results.length.should == 5
      found = results.find_all { |result| user1.id.to_s == result[:id].to_s }
      found[0][:score].should == 1000.0
    end 

    it 'reads from the friend leaderboard consecutively, caching enabled' do 
      lb_service = LeaderboardService.new('fizzbuzz', user1.id, 10.minutes)
      lb_service.update_global_leaderboard(900.0)

      api_status, results = lb_service.friends_leaderboard
      results.length.should == 5
      found = results.find_all { |result| user1.id.to_s == result[:id].to_s }
      found[0][:score].should == 900.0

      # A new high score
      lb_service.update_global_leaderboard(1000.0)
      api_status, results = lb_service.friends_leaderboard
      results.length.should == 5
      found = results.find_all { |result| user1.id.to_s == result[:id].to_s }
      found[0][:score].should == 900.0 # The new high score is not seen
    end
  end

end

