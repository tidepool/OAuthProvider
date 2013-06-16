require 'spec_helper'

describe 'Preorders API' do 
  include AppConnections

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:user1) { create(:user) }
  let(:preorder) { create(:preorder, user: user1) }

  it 'records the preorder from a user' do
    token = get_conn(user1)
    response = token.post("#{@endpoint}/users/-/preorders.json")
    response.status.should == 200        
    preorder_result = JSON.parse(response.body, symbolize_names: true)
    preorder_result[:user_id].should == user1.id

    preorder = Preorder.find(preorder_result[:id])
    preorder.user.should == user1
  end
end