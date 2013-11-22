require 'spec_helper'

describe ActivityStreamService do
  include FriendHelpers

  let(:user1) { create(:user, name: 'John Doe') }
  let(:friend_list) { create_list(:friend_user, 7)}
  let(:make_friends_activity) { create_list(:make_friends_activity, 5, user: user1)}
  let(:high_score_activity) { create_list(:high_score_activity, 5, user: user1)}

  before :each do 
    create_friends(user1, friend_list[0..3])
  end

  it 'registers an activity for all friends of a user' do 
    activity_stream = ActivityStreamService.new
    make_friends_activity[0..2].each do |activity|
      activity_stream.register_activity(user1.id, activity)
    end

    user1_stream_count = $redis.zcount "activity_stream:#{user1.id}", "-inf", "+inf"
    user1_stream_count.should == 3

    friend_list[0..3].each do |friend|
      stream_count = $redis.zcount "activity_stream:#{friend.id}", "-inf", "+inf"
      stream_count.should == 3
    end    

    friend_list[4..6].each do |friend|
      stream_count = $redis.zcount "activity_stream:#{friend.id}", "-inf", "+inf"
      stream_count.should == 0
    end        
  end
end