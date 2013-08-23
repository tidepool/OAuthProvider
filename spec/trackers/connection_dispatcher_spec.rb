require 'spec_helper'

describe ConnectionDispatcher do
  let(:user) { create(:user) }
  let(:connection_list) { create_list(:fitbit, 10, user:user)}
  let(:recently_sync_list) { create_list(:fitbit, 10, last_accessed: Time.now - 10.minutes, user:user) }

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
    TrackerDispatcher.stub(:perform_async) do |connection_id|
      TrackerDispatcher.new.perform(connection_id)
    end
  end

  it 'synchronizes connections' do 
    connection_list
    options = {
      batch_size: 3,
      time_ago: 1.seconds,
      supported_providers: ['fitbit']
    }
    conn_dispatcher = ConnectionDispatcher.new
    conn_dispatcher.perform(options)

    connections = Authentication.where(provider:'fitbit').limit(10)
    connections.each do |conn|
      conn.sync_status.should == 'synchronized'
    end
  end

  it 'does not synchronize connections if they are synchronized recently' do
    last_accessed = recently_sync_list[0].last_accessed
    options = {
      batch_size: 3,
      time_ago: 20.minutes,
      supported_providers: ['fitbit']
    }
    conn_dispatcher = ConnectionDispatcher.new
    conn_dispatcher.perform(options)

    connections = Authentication.where(provider:'fitbit').limit(10)
    connections.each do |conn|
      conn.last_accessed.should == last_accessed
      conn.sync_status.should == 'not_synchronized'
    end
  end

  it 'does synchronize connections if they are not synchronized recently' do
    last_accessed = recently_sync_list[0].last_accessed
    options = {
      batch_size: 15,
      time_ago: 5.minutes,
      supported_providers: ['fitbit']
    }
    conn_dispatcher = ConnectionDispatcher.new
    conn_dispatcher.perform(options)

    connections = Authentication.where(provider:'fitbit').limit(10)
    connections.each do |conn|
      conn.last_accessed.should_not == last_accessed
      conn.sync_status.should == 'synchronized'
    end
  end

end