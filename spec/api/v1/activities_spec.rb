require 'spec_helper'

describe 'Activities API' do 
  include AppConnections

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:user1) { create(:user) }
  let(:activity_list) { create_list(:activities, 5, user: user1) }
  let(:other_activity_list) { create_list(:activities, 5, user: user1, provider: 'foo') }

  it 'gets a list of activities for the user' do
    activity_list
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/activities.json")
    response.status.should == 200        
    activities = JSON.parse(response.body, symbolize_names: true)
    activities.should_not be_nil
    activities.length.should == 5
  end

  it 'gets a list of activities for a given provider for the user' do
    activity_list
    other_activity_list
    all_activities = Activity.all
    all_activities.length.should == 10

    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/activities.json?provider=fitbit")
    response.status.should == 200        
    activities = JSON.parse(response.body, symbolize_names: true)
    activities.should_not be_nil
    activities.length.should == 5
  end

end