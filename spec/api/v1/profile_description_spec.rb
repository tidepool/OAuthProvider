require 'spec_helper'

describe 'ProfileDescription API' do 
  include AppConnections

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  it 'returns the profile description for anonymous users' do 
    token = get_conn()

    response = token.get("#{@endpoint}/personality/the-chief-executive.json")
    result = JSON.parse(response.body, symbolize_names: true)
    desc = result[:data]
    desc[:name].should == "The Chief Executive"
    desc[:big5_dimension].should == "high_extraversion"
    desc[:description].should_not be_empty
  end

  it 'returns an error if the profile does not exist' do 
    token = get_conn()

    response = token.get("#{@endpoint}/personality/foo.json")
    result = JSON.parse(response.body, symbolize_names: true)
    status = result[:status]
    status[:code].should == 1001
    status[:message].should == "foo is not a valid profile description."
  end
end