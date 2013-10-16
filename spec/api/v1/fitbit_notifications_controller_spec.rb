require 'spec_helper'

describe 'Fitbit Notifications Endpoint' do 
  include AppConnections

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  it 'handles the notifications from Fitbit' do 
    TrackerDispatcher.stub(:perform_async) do | conn_id, provider, updates|
      conn_id.should == 0
      provider.should == 'fitbit'
      updates = JSON.parse(updates, symbolize_names: true) if updates.class == String
      updates.should_not be_nil
      updates.length.should == 2
      updates[0][:collectionType].should == "sleep"
    end

    anon_client = Faraday.new do |f|
      f.request :multipart
      f.request :url_encoded
      f.adapter :rack, Rails.application
    end      
    path = Rails.root.join("spec/fixtures/fitbit_payload.json")
    payload = { :updates => Faraday::UploadIO.new(path.to_s, 'application/json') }

    response = anon_client.post("#{@endpoint}/fitbit", payload )
    response.status.should == 204
  end 
end
