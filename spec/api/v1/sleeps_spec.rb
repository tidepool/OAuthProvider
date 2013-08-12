require 'spec_helper'

describe 'Sleeps API' do 
  include AppConnections

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:user1) { create(:user) }
  let(:sleep_list) { create_list(:sleeps, 5, user: user1) }
  let(:other_sleep_list) { create_list(:sleeps, 5, user: user1, provider: 'foo') }

  it 'gets a list of sleeps for the user' do
    sleep_list
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/sleeps.json")
    response.status.should == 200        
    result = JSON.parse(response.body, symbolize_names: true)
    sleeps = result[:data]
    sleeps.should_not be_nil
    sleeps.length.should == 5
  end

  it 'gets a list of sleeps for a given provider for the user' do
    sleep_list
    other_sleep_list
    all_sleeps = Sleep.all
    all_sleeps.length.should == 10

    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/sleeps.json?provider=fitbit")
    response.status.should == 200        
    result = JSON.parse(response.body, symbolize_names: true)
    sleeps = result[:data]
    sleeps.should_not be_nil
    sleeps.length.should == 5
  end
end