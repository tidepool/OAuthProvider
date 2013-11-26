require 'spec_helper'

describe 'Activity Stream API' do 
  include AppConnections
  include ActivityStreamHelpers

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:user1) { create(:friend_user, name: 'John Doe') }
  let(:make_friends) { create_list(:make_friends_activity, 5, user: user1)}
  let(:high_score) { create_list(:high_score_activity, 5, user: user1)}

  context 'gets a list of activities for a user' do 
    before :each do 
      create_activity(user1.id, make_friends)
      create_activity(user1.id, high_score)      
    end

    it 'gets a list of activities for a user' do 
      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/activity_stream.json")
      result = JSON.parse(response.body, symbolize_names: true)
      activities = result[:data]
      activities.length.should == 10
      types = activities.map { |activity| activity[:type] }
      types.should include("MakeFriendsActivity", "HighScoreActivity")
      activities[0][:description].should_not be_empty
      activities[0][:user_name].should_not be_nil
      activities[0][:user_image].should_not be_nil
      status = result[:status]
      status.should == {
             :offset => 0,
              :limit => 20,
        :next_offset => 0,
         :next_limit => 20,
              :total => 10
      }
    end
  end

end