require 'spec_helper'

describe 'Connections API' do
  include AppConnections

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:authentication1) { create(:authentication, user: user1)}

  it 'receives the activated and not activated connections' do
    authentication1
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

end