require 'spec_helper'

describe 'Recommendations API' do 
  include AppConnections

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:personality) { create(:personality, profile_description_id: 3) }
  let(:user1) { create(:user, personality: personality) }
  let(:user2) { create(:user) }

  it 'gets a random recommendation for a given big5_dimension for user' do
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/recommendations/latest.json")
    response.status.should == 200        
    reco_result = JSON.parse(response.body, symbolize_names: true)
    reco_result[:big5_dimension].should == "high_openness"
    reco_result[:sentence].should_not be_nil
    reco_result[:link_title].should_not be_nil
    reco_result[:link].should_not be_nil
    reco_result[:link_type].should_not be_nil
    reco_result[:icon_url].should_not be_nil
  end

  it 'gets a career recommendation for a given user' do
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/recommendations/career.json")
    response.status.should == 200
    reco_result = JSON.parse(response.body, symbolize_names: true)
    reco_result[:careers].length.should == 4
    reco_result[:careers][3].should == "Life coach"
    reco_result[:tools].length.should == 3
    reco_result[:tools][0].should == "Analytic and scientific software"
    reco_result[:skills].length.should == 2
    reco_result[:skills][1].should == "General psychology training"
  end
end