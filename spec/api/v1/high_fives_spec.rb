require 'spec_helper'

describe 'High Fives API' do 
  include AppConnections
  include ActivityStreamHelpers

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:user1) { create(:friend_user, name: 'John Doe') }
  let(:make_friends) { create(:make_friends_activity, user: user1)}
  let(:highfive) { create(:highfive, user: user1, activity_record: make_friends) }
  let(:highfives) { create_list(:highfive, 15, user: user1, activity_record: make_friends) }

  it 'shows highfives for a given activity' do
    highfives

    token = get_conn(user1)
    response = token.get("#{@endpoint}/feeds/#{make_friends.id}/highfives.json?offset=0&limit=5")
    result = JSON.parse(response.body, symbolize_names: true)
    highfives = result[:data]
    highfives.length.should == 5
    highfives[0][:user_name].should_not be_nil
    highfives[0][:user_image].should_not be_nil
    status = result[:status]
    status.should == {
           :offset => 0,
            :limit => 5,
      :next_offset => 5,
       :next_limit => 5,
            :total => 15
    }
  end

  it 'creates a new highfive for a given activity' do 
    token = get_conn(user1)

    response = token.post("#{@endpoint}/feeds/#{make_friends.id}/highfives.json")
    result = JSON.parse(response.body, symbolize_names: true)
    highfive = result[:data]

    created_highfive = Highfive.find(highfive[:id])
    created_highfive.id.should == highfive[:id] 
  end

  it 'deletes a highfive' do 
    highfive
    token = get_conn(user1)
    response = token.delete("#{@endpoint}/highfives/#{highfive.id}.json")
    result = JSON.parse(response.body, symbolize_names: true)
    response.status.should == 200

    deleted_highfive = Highfive.where(id: highfive.id).first
    deleted_highfive.should be_nil
  end
end

