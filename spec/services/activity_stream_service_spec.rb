require 'spec_helper'

describe ActivityStreamService do
  include FriendHelpers
  include ActivityStreamHelpers

  let(:user1) { create(:user, name: 'John Doe') }
  let(:friend_list) { create_list(:friend_user, 7)}
  let(:make_friends_activity) { create_list(:make_friends_activity, 5, user: user1)}
  let(:high_score_activities) { create_list(:high_score_activity, 5, user: user1)}

  it 'registers a MakeFriendsActivity' do 
    create_friends(user1, friend_list[0..3])
    activity_stream = ActivityStreamService.new

    user1_stream_count = $redis.zcount "activity_stream:#{user1.id}", "-inf", "+inf"
    user1_stream_count.should == 4

    friend_list[0..3].each do |friend|
      stream_count = $redis.zcount "activity_stream:#{friend.id}", "-inf", "+inf"
      stream_count.should == 1
    end    

    create_friends(user1, friend_list[4..5])

    user1_stream_count = $redis.zcount "activity_stream:#{user1.id}", "-inf", "+inf"
    user1_stream_count.should == 6

    friend_list[0..3].each do |friend|
      stream_count = $redis.zcount "activity_stream:#{friend.id}", "-inf", "+inf"
      stream_count.should == 1
    end    

    friend_list[4..5].each do |friend|
      stream_count = $redis.zcount "activity_stream:#{friend.id}", "-inf", "+inf"
      stream_count.should == 1
    end        

    stream_count = $redis.zcount "activity_stream:#{friend_list[6].id}", "-inf", "+inf"
    stream_count.should == 0
  end


  it 'returns the highfives count for all activity records' do 
    create_activity(user1.id, high_score_activities)
    create_highfives(user1.id, high_score_activities)

    activity_stream = ActivityStreamService.new
    activity_records, api_status = activity_stream.read_activity_stream(user1.id)
    activity_records.length.should == 5
  end
end