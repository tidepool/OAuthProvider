require 'spec_helper'

describe 'Basic access to APIs' do
  include AppConnections

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end
  let(:user1) { create(:user) }

  it 'gets the token' do
    token = get_conn(user1)
    token.should_not be_expired
  end

  it 'denies token for wrong pass' do
    lambda { get_conn(user1, 'foo')}.should raise_error(OAuth2::Error)
  end
end
