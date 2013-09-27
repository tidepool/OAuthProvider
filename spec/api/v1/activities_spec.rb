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
  let(:paginated_activity_list) { create_list(:activities, 20, user: user1, provider: 'fitbit')}

  it 'gets a list of activities for the user' do
    activity_list
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/activities.json")
    response.status.should == 200        
    result = JSON.parse(response.body, symbolize_names: true)
    activities = result[:data]
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
    result = JSON.parse(response.body, symbolize_names: true)
    activities = result[:data]
    activities.should_not be_nil
    activities.length.should == 5
  end

  it 'gets the activities in a paginated list' do 
    paginated_activity_list
    expected = Activity.where(user_id: user1.id).where(provider: 'fitbit').order(:date_recorded).limit(10).offset(5)

    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/activities.json?provider=fitbit&offset=5&limit=10")
    response.status.should == 200        
    result = JSON.parse(response.body, symbolize_names: true)
    activities = result[:data]
    activities.length.should == 10
    activities[0][:id].should == expected.first.id

    status = result[:status]
    status[:offset].should == 5
    status[:limit].should == 10
  end

  it 'gets no results if the offset is larger than the number of records' do 
    paginated_activity_list
    expected = Activity.where(user_id: user1.id).where(provider: 'fitbit').order(:date_recorded).limit(10).offset(25)

    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/activities.json?provider=fitbit&offset=25&limit=10")
    response.status.should == 200        
    result = JSON.parse(response.body, symbolize_names: true)
    activities = result[:data]
    activities.length.should == 0
  end
end