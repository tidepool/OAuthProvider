require 'spec_helper'

describe 'Users API' do 
  include AppConnections

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:guest) { create(:guest) }
  let(:admin) { create(:admin) }
  let(:game) { create(:game, user: guest) }

  it 'shows the users own information' do    
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-.json")
    user_info = JSON.parse(response.body, symbolize_names: true)
    user_info[:email].should == user1.email
  end

  it 'creates a user' do 
    # When users sign-up the user is created using this API
    token = get_conn()
    user_params = { email: 'test_user@example.com', password: '12345678', password_confirmation: '12345678' }
    response = token.post("#{@endpoint}/users.json", { user: user_params } )
    user_info = JSON.parse(response.body, symbolize_names: true)
    user_info[:email].should == user_params[:email]
    user = User.find(user_info[:id])
    user.email.should == user_params[:email]
  end

  it 'updates a users information' do 
    token = get_conn(user1)
    user_params = { name: 'John Doe', city: 'Istanbul' }
    response = token.put("#{@endpoint}/users/#{user1.id}.json", {body: {user: user_params}})
    user_info = JSON.parse(response.body, symbolize_names: true)
    user_info[:name].should == user_params[:name]
    user_info[:city].should == user_params[:city]
  end

  it 'deletes a user' do
    token = get_conn(user1)
    user_id = user1.id
    response = token.delete("#{@endpoint}/users/-.json")
    lambda { User.find(user_id) }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it 'creates a guest user' do
    token = get_conn()
    user_params = { guest: true }
    response = token.post("#{@endpoint}/users.json", { user: user_params } )
    user_info = JSON.parse(response.body, symbolize_names: true)
    user_info[:guest].should == true
    user = User.find(user_info[:id])
    user.guest.should == true
    expect(user.email.index('guest')).to eq(0)
  end

  it 'updates a guest user to a registered user using email, password' do
    token = get_conn(guest)
    user_params = { email: 'test_user@example.com', password: '12345678', password_confirmation: '12345678' }
    response = token.put("#{@endpoint}/users/#{guest.id}.json", {body: {user: user_params}})
    user_info = JSON.parse(response.body, symbolize_names: true)
    user_info[:guest].should == false
    user_info[:email].should == user_params[:email]
  end

  it 'gets a users profile results' do
    token = get_conn(user1)
    response = token.get("")
  end

  describe 'Error and Edge Cases' do
    it 'doesnot show other users information' do 
      token = get_conn(user1)
      lambda { token.get("#{@endpoint}/users/#{guest.id}.json") }.should raise_error(Api::V1::UnauthorizedError)
    end

    it 'doesnot give anonymous access to user info' do 
      token = get_conn()
      lambda { token.get("#{@endpoint}/users/#{guest.id}.json") }.should raise_error(Api::V1::UnauthorizedError)      
    end

    it 'doesnot update another users information' do
      token = get_conn(user1)
      user_params = { name: 'John Doe', city: 'Istanbul' }
      lambda { token.put("#{@endpoint}/users/#{user2.id}.json", {body: {user: user_params}})}.should raise_error(Api::V1::UnauthorizedError)
    end

    it 'doesnot create a user with overlapping email' do 
      token = get_conn()
      user_params = { email: user1.email, password: '12345678', password_confirmation: '12345678' }
      lambda {token.post("#{@endpoint}/users.json", { user: user_params } )}.should raise_error(ActiveRecord::RecordInvalid)
    end    

    it 'doesnot create a user with wrong password_confirmation' do
      token = get_conn()
      user_params = { email: 'test_user@example.com', password: '12345678', password_confirmation: '22225678' }
      lambda {token.post("#{@endpoint}/users.json", { user: user_params } )}.should raise_error(ActiveRecord::RecordInvalid)
    end

    it 'doesnot delete another user than the caller' do
      token = get_conn(user1)
      user_id = user1.id
      lambda { token.delete("#{@endpoint}/users/#{user2.id}.json")}.should raise_error(Api::V1::UnauthorizedError)
      user = User.find(user_id)
      user.email.should == user1.email
    end

    it 'doesnot allow a user to have password less than 8 length' do
      token = get_conn()
      user_params = { email: 'test_user@example.com', password: '1234567', password_confirmation: '1234567' }
      lambda {token.post("#{@endpoint}/users.json", { user: user_params } )}.should raise_error(ActiveRecord::RecordInvalid)
    end

    it 'doesnot allow a user to change its status to be guest' do
      token = get_conn(user1)
      user_params = { guest: true }
      response = token.put("#{@endpoint}/users/#{user1.id}.json", {body: {user: user_params}})
      user_info = JSON.parse(response.body, symbolize_names: true)
      user_info[:guest].should == false
    end
      
  end
end