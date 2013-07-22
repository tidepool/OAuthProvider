require 'spec_helper'
require 'fitgem'

describe 'Connections API' do
  include AppConnections

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  before :each do 
    Fitgem::Client.any_instance.stub(:activities_on_date).and_return({
      "summary" => {
        "steps"=>9663,
        "veryActiveMinutes"=>30
        }
      })
    Fitgem::Client.any_instance.stub(:sleep_on_date).and_return({
      "summary" => {
        "totalMinutesAsleep"=>360,
        "totalTimeInBed"=>400
        }
      })
    Fitgem::Client.any_instance.stub(:foods_on_date).and_return({
      "summary" => {
        "calories"=>2300,
        "water"=>5
        }
      })
    Fitgem::Client.any_instance.stub(:body_measurements_on_date).and_return({
      "body" => {
        "bmi"=>25,
        "weight"=>150
        }
      })
    TrackerDispatcher.stub(:perform_async) do |user_id|
      TrackerDispatcher.new.perform(user_id)
    end
  end

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:facebook) { create(:authentication, user: user1)}
  let(:fitbit) { create(:fitbit, user: user1)}

  it 'receives the activated and not activated connections' do
    facebook
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/connections.json")
    response.status.should == 200        
    connections = JSON.parse(response.body, symbolize_names: true)
    expect(connections).to_not be_nil

    connections.each do |connection|
      if connection[:provider] == 'facebook'
        expect(connection[:activated]).to be_true
      end
    end
  end

  it 'starts synchronizing the provider data' do
    fitbit
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/connections/fitbit/synchronize.json")
    response.status.should == 202        
    api_status = JSON.parse(response.body, symbolize_names: true)
    api_status[:status][:link].should == "http://example.org#{@endpoint}/users/-/connections/fitbit/progress.json"
    api_status[:status][:message].should == "Starting to synchronize #{fitbit.provider}"
    api_status[:status][:state].should == 'pending'
  end

  it 'does not restart the synchronization if synchronize is called twice' do 
    TrackerDispatcher.stub(:perform_async) do |user_id|
      # Do nothing
    end

    fitbit
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/connections/fitbit/synchronize.json")
    response.status.should == 202   
    response = token.get("#{@endpoint}/users/-/connections/fitbit/synchronize.json")
    response.status.should == 200
    api_status = JSON.parse(response.body, symbolize_names: true)
    api_status[:status][:link].should == "http://example.org#{@endpoint}/users/-/connections/fitbit/progress.json"
    api_status[:status][:message].should == "Synchronization is already in progress."
    api_status[:status][:state].should == 'pending'   
  end

  it 'the progress completes when the provider data is synchronized' do 
    fitbit
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/connections/fitbit/synchronize.json")
    response.status.should == 202        
    api_status = JSON.parse(response.body, symbolize_names: true)

    is_done = false
    # Start polling for progress
    response = token.get(api_status[:status][:link])
    api_status = JSON.parse(response.body, symbolize_names: true)
    response.status.should == 200
    if api_status[:status][:state] == 'done'
      activities = Activity.where('user_id = ? and provider = ?', user1, 'fitbit').order(:date_recorded)    
      activities.length.should == 3
      activities[0].date_recorded.should == Date.current - 2.days
      activities[0].steps.should == 9663
      activities[0].very_active_minutes.should == 30
      is_done = true
    end
    is_done.should == true
    connection = Authentication.find(fitbit.id)
    connection.sync_status.should == "synchronized"
    connection.last_accessed.should > Time.zone.now - 2.minutes
  end

  it 'returns an error if the provider is not active' do 
    token = get_conn(user1)
    expect{token.get("#{@endpoint}/users/-/connections/fitbit/synchronize.json")}.to raise_error(OAuth2::Error)
    
    # response.status.should == 202        
    # api_status = JSON.parse(response.body, symbolize_names: true)
    # api_status[:status][:message].should == "Provider fitbit connection is not active."
  end

  it 'returns an error if the synchronization cannot complete' do 
    Fitgem::Client.any_instance.stub(:activities_on_date).and_return({
      "errors" =>
        [{  "errorType"=>"oauth",
            "fieldName"=>"oauth_access_token",
             "message"=> "Invalid signature or token" }]
      })

    fitbit
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/connections/fitbit/synchronize.json")
    response.status.should == 202        
    api_status = JSON.parse(response.body, symbolize_names: true)
    # Start polling for progress
    response = token.get(api_status[:status][:link])
    api_status = JSON.parse(response.body, symbolize_names: true)
    response.status.should == 200
    api_status[:status][:state].should == 'authentication_error'
    api_status[:status][:message].should == 'Error authenticating.'
  end

  it 'keeps pending if the synchronization is taking time' do 
    TrackerDispatcher.stub(:perform_async) do |user_id|
      # Do nothing
    end
    fitbit
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/connections/fitbit/synchronize.json")
    response.status.should == 202        
    api_status = JSON.parse(response.body, symbolize_names: true)
    # Start polling for progress
    response = token.get(api_status[:status][:link])
    api_status = JSON.parse(response.body, symbolize_names: true)
    response.status.should == 200
    api_status[:status][:state].should == 'pending'
    api_status[:status][:message].should == 'Synchronization is in progress.'
    api_status[:status][:link].should == "http://example.org#{@endpoint}/users/-/connections/fitbit/progress.json"

  end
end