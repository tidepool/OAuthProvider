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
  let(:personality) { create(:personality) }
  let(:user3) { create(:user, personality: personality) }
  let(:game) { create(:game, user: guest) }
  let(:authentication) { create(:authentication, user: user2) }
  let(:aggregate_result) { create(:aggregate_result, user: user2) }
  let(:sleep_aggregate_result) { create(:aggregate_result, type: 'SleepAggregateResult', user: user2) }
  let(:activity_aggregate_result) { create(:aggregate_result, type: 'ActivityAggregateResult', user: user2) }

  it 'shows the users own information' do    
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-.json")
    result = JSON.parse(response.body, symbolize_names: true)
    user_info = result[:data]
    user_info[:email].should == user1.email
  end

  it 'shows the users authentication info' do 
    authentication
    token = get_conn(user2)
    response = token.get("#{@endpoint}/users/-.json")
    result = JSON.parse(response.body, symbolize_names: true)
    user_info = result[:data]
    user_info[:authentications].length.should == 1
    user_info[:authentications][0][:provider].should == 'facebook'
    user_info[:authentications][0][:oauth_token].should == '123456'
    user_info[:authentications][0][:oauth_secret].should == '232323'
  end

  it 'creates a user' do 
    # When users sign-up the user is created using this API
    token = get_conn()
    user_params = { email: 'test_user@example.com', password: '12345678', password_confirmation: '12345678' }
    response = token.post("#{@endpoint}/users.json", { user: user_params } )
    result = JSON.parse(response.body, symbolize_names: true)
    user_info = result[:data]
    user_info[:email].should == user_params[:email]

    user = User.find(user_info[:id])
    user.email.should == user_params[:email]
  end

  it 'creates a registered user with the referred_by attribute' do 
    token = get_conn()
    user_params = { email: 'test_user@example.com', password: '12345678', password_confirmation: '12345678', referred_by: 'Hesston' }
    response = token.post("#{@endpoint}/users.json", { user: user_params } )
    result = JSON.parse(response.body, symbolize_names: true)
    user_info = result[:data]
    user_info[:referred_by].should == user_params[:referred_by]
    
    user = User.find(user_info[:id])
    user.referred_by.should == user_params[:referred_by]
  end

  it 'updates a users information' do 
    token = get_conn(user1)
    user_params = { name: 'John Doe', 
      display_name: 'johndoe', 
      description: 'I am John Doe',
      city: 'Istanbul',
      state: 'CA',
      country: 'Turkey',
      timezone: 2,
      locale: 'en-us',
      image: 'http://example.com/image.jpg',
      gender: 'male',
      date_of_birth: Date.new(1970, 3, 25), 
      education: 'High School',
      handedness: 'left', 
      referred_by: 'Hesston', 
      ios_device_token: "1232321313",
      android_device_token: "44443224",
      is_dob_by_age: true
    }
    response = token.put("#{@endpoint}/users/#{user1.id}.json", {body: {user: user_params}})
    result = JSON.parse(response.body, symbolize_names: true)
    user_info = result[:data]

    user_info[:name].should == user_params[:name]
    user_info[:city].should == user_params[:city]
    user_info[:date_of_birth].should == user_params[:date_of_birth].to_s
    user_info[:description].should == user_params[:description]
    user_info[:state].should == user_params[:state]
    user_info[:country].should == user_params[:country]
    user_info[:timezone].should == user_params[:timezone].to_s
    user_info[:locale].should == user_params[:locale]
    user_info[:image].should == user_params[:image]
    user_info[:gender].should == user_params[:gender]
    user_info[:education].should == user_params[:education]
    user_info[:handedness].should == user_params[:handedness]
    user_info[:referred_by].should == user_params[:referred_by]
    user_info[:ios_device_token].should == user_params[:ios_device_token] 
    user_info[:android_device_token].should == user_params[:android_device_token] 
    user_info[:is_dob_by_age].should == user_params[:is_dob_by_age]  
  end

  it 'updates a users information also in the database' do
    # There is a bug which fails the validations for user due to has_secure_password
    # To make sure it does not creep in, I added this test
    # https://github.com/rails/rails/pull/6215

    token = get_conn(user1)
    user_params = { name: 'John Doe', city: 'Istanbul'}
    response = token.put("#{@endpoint}/users/#{user1.id}.json", {body: {user: user_params}})
    result = JSON.parse(response.body, symbolize_names: true)
    user_info = result[:data]
    updated_user = User.find(user_info[:id])
    updated_user.city.should == user_params[:city]
    updated_user.name.should == user_params[:name]
  end

  it 'updates a users information also in the database, when the user_id is -' do
    token = get_conn(user1)
    user_params = { name: 'John Doe', city: 'Istanbul'}
    response = token.put("#{@endpoint}/users/-.json", {body: {user: user_params}})
    result = JSON.parse(response.body, symbolize_names: true)
    user_info = result[:data]
    updated_user = User.find(user_info[:id])
    updated_user.city.should == user_params[:city]
    updated_user.name.should == user_params[:name]
  end

  it 'deletes a user' do
    token = get_conn(user1)
    user_id = user1.id
    response = token.delete("#{@endpoint}/users/#{user_id}.json")
    lambda { User.find(user_id) }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it 'deletes a user when the user_id is -' do
    token = get_conn(user1)
    user_id = user1.id
    response = token.delete("#{@endpoint}/users/-.json")
    lambda { User.find(user_id) }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it 'creates a guest user' do
    token = get_conn()
    user_params = { guest: true }
    response = token.post("#{@endpoint}/users.json", { user: user_params } )
    result = JSON.parse(response.body, symbolize_names: true)
    user_info = result[:data]
    user_info[:guest].should == true
    user = User.find(user_info[:id])
    user.guest.should == true
    expect(user.email.index('guest')).to eq(0)
  end

  it 'creates a guest user with referred_by attribute' do
    token = get_conn()
    user_params = { guest: true, referred_by: 'Hesston' }
    response = token.post("#{@endpoint}/users.json", { user: user_params } )
    result = JSON.parse(response.body, symbolize_names: true)
    user_info = result[:data]

    user_info[:guest].should == true
    user_info[:referred_by].should == 'Hesston'

    user = User.find(user_info[:id])
    user.guest.should == true
    user.referred_by.should == user_params[:referred_by]
  end

  it 'updates a guest user to a registered user using email, password' do
    token = get_conn(guest)
    user_params = { email: 'test_user@example.com', password: '12345678', password_confirmation: '12345678' }
    response = token.put("#{@endpoint}/users/#{guest.id}.json", {body: {user: user_params}})
    result = JSON.parse(response.body, symbolize_names: true)
    user_info = result[:data]
    user_info[:guest].should == false
    user_info[:email].should == user_params[:email]
  end

  it 'gets a users personality when user_id is specified' do
    personality 
    token = get_conn(user3)
    response = token.get("#{@endpoint}/users/#{user3.id}/personality.json")
    result = JSON.parse(response.body, symbolize_names: true)
    user_info = result[:data]
    user_info[:big5_dimension].should == personality.big5_dimension
    user_info[:holland6_dimension].should == personality.holland6_dimension
    user_info[:big5_high].should == personality.big5_high
    user_info[:big5_low].should == personality.big5_low
    user_info[:big5_score].should == personality.big5_score.symbolize_keys
    user_info[:holland6_score].should == personality.holland6_score.symbolize_keys
  end

  it 'gets a users personality when user_id is -' do
    personality 
    token = get_conn(user3)
    response = token.get("#{@endpoint}/users/-/personality.json")
    result = JSON.parse(response.body, symbolize_names: true)
    user_info = result[:data]
    user_info[:big5_dimension].should == personality.big5_dimension
    user_info[:holland6_dimension].should == personality.holland6_dimension
    user_info[:big5_high].should == personality.big5_high
    user_info[:big5_low].should == personality.big5_low
    user_info[:big5_score].should == personality.big5_score.symbolize_keys
    user_info[:holland6_score].should == personality.holland6_score.symbolize_keys
  end

  it 'allows the user to reset their password given their email' do 
    user1
    MailSender.stub(:perform_async) do |mailer_klass_name, mailer_method, options|
      options[:user_id].should == user1.id
      options[:temp_password].should_not be_nil
    end
    token = get_conn()
    user_params = { email: user1.email }
    response = token.post("#{@endpoint}/users/-/reset_password.json", {user: user_params})

    result = JSON.parse(response.body, symbolize_names: true)
    response.status.should == 200
    result[:status][:message].should == "Password is reset, and email sent with temporary password."
  end

  it 'returns the aggregate_result for the user' do 
    aggregate_result
    sleep_aggregate_result
    activity_aggregate_result
    token = get_conn(user2)
    response = token.get("#{@endpoint}/users/-.json")
    result = JSON.parse(response.body, symbolize_names: true)
    user_info = result[:data]
    user_info[:aggregate_results].length.should == 3
    # Always ensure the first aggregate result is SpeedAggregateResult, because of a backwards compat
    # bug in the iOS client.
    user_info[:aggregate_results][0][:type].should == 'SpeedAggregateResult'
  end

  describe 'Error and Edge Cases' do
    it 'doesnot show other users information' do 
      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/#{guest.id}.json") 
      response.status.should == 401
      result = JSON.parse(response.body, symbolize_names: true)
      result[:status][:code].should == 1000
    end

    it 'doesnot give anonymous access to user info' do 
      token = get_conn()
      response = token.get("#{@endpoint}/users/#{guest.id}.json")
      response.status.should == 401
      result = JSON.parse(response.body, symbolize_names: true)
      result[:status][:code].should == 1000           
    end

    it 'doesnot update another users information' do
      token = get_conn(user1)
      user_params = { name: 'John Doe', city: 'Istanbul' }
      response = token.put("#{@endpoint}/users/#{user2.id}.json", {body: {user: user_params}})
      response.status.should == 401
      result = JSON.parse(response.body, symbolize_names: true)
      result[:status][:code].should == 1000                 
    end

    it 'doesnot create a user with overlapping email' do 
      token = get_conn()
      user_params = { email: user1.email, password: '12345678', password_confirmation: '12345678' }
      response = token.post("#{@endpoint}/users.json", { user: user_params } )
      response.status.should == 422
      result = JSON.parse(response.body, symbolize_names: true)
      result[:status][:code].should == 1002                 
    end    

    it 'doesnot create a user with wrong password_confirmation' do
      token = get_conn()
      user_params = { email: 'test_user@example.com', password: '12345678', password_confirmation: '22225678' }
      response = token.post("#{@endpoint}/users.json", { user: user_params } )
      response.status.should == 422
      result = JSON.parse(response.body, symbolize_names: true)
      result[:status][:code].should == 1002                       
    end

    it 'doesnot delete another user than the caller' do
      token = get_conn(user1)
      user_id = user1.id
      response = token.delete("#{@endpoint}/users/#{user2.id}.json")
      response.status.should == 401
      result = JSON.parse(response.body, symbolize_names: true)
      result[:status][:code].should == 1000                       
      user = User.find(user_id)
      user.email.should == user1.email
    end

    it 'doesnot allow a user to have password less than 8 length' do
      token = get_conn()
      user_params = { email: 'test_user@example.com', password: '1234567', password_confirmation: '1234567' }
      response = token.post("#{@endpoint}/users.json", { user: user_params } )
      response.status.should == 422
      result = JSON.parse(response.body, symbolize_names: true)
      result[:status][:code].should == 1002                             
    end

    it 'doesnot allow a user to change its status to be guest' do
      token = get_conn(user1)
      user_params = { guest: true }
      response = token.put("#{@endpoint}/users/#{user1.id}.json", {body: {user: user_params}})
      result = JSON.parse(response.body, symbolize_names: true)
      user_info = result[:data]
      user_info[:guest].should == false
    end
    
    # it 'doesnot allow to change the referred_by attribute' do 
    #   token = get_conn(user1)
    #   user_params = { referred_by: 'Hesston' }
    #   response = token.put("#{@endpoint}/users/#{user1.id}.json", {body: {user: user_params}})
    #   result = JSON.parse(response.body, symbolize_names: true)
    #   user_info = result[:data]
    #   user = User.find(user_info[:id])
    #   user.referred_by.should_not == 'Hesston'
    # end

  end
end