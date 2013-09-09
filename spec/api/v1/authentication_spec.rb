require 'spec_helper'

describe 'Authentications API' do 
  include AppConnections

  before :all do
    find_or_create_app
    @endpoint = "oauth/authorize"
  end

  before :each do 
    @payload = {
      "grant_type" => "password",
      "response_type" => "password",
      "client_id" => @app.uid,
      "client_secret" => @app.secret
    }
  end

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:authentication) { create(:authentication, user: user2) }

  it 'creates a new user and returns info' do 
    token = get_conn()
    @payload["email"] = "test_user@test.co"
    @payload["password"] = "12345678"
    @payload["password_confirmation"] = "12345678"
    response = token.post("#{@endpoint}", @payload)
    result = JSON.parse(response.body, symbolize_names: true)
    user_info = result
    user_info[:access_token].should_not be_nil
    user_info[:user][:email].should == @payload["email"]
    user_info[:token_type].should == "bearer"
  end

  it 'logs in an existing user from username and password' do 
    user1
    token = get_conn()
    @payload["email"] = user1.email
    @payload["password"] = "12345678"
    response = token.post("#{@endpoint}", @payload)
    result = JSON.parse(response.body, symbolize_names: true)
    user_info = result
    user_info[:access_token].should_not be_nil
    user_info[:user][:email].should == @payload["email"]
    user_info[:token_type].should == "bearer"    
  end

  #   "auth_hash": 
  #     {
  #       "provider": "facebook",
  #       "uid": "facebook user id",           # Maps to com.facebook.sdk:TokenInformationUserFBIDKey
  #       "info": {
  #         "email": "email",
  #         "name": "name",
  #         "image": "image_url",
  #         "location" : "location",
  #         "gender" : "male",
  #         "dob" : "1911-11-23"
  #       },
  #       "extra": {
  #         "raw_info": {
  #           "gender" : "male",
  #           "dob" : "1911-11-23"
  #         }
  #       },
  #       "credentials": {
  #         "token": "facebook token",                      # Maps to com.facebook.sdk:TokenInformationTokenKey
  #         "secret": "for Oauth 1.0 providers only",
  #         "refresh_at": "2013-07-31T15:17:35.520-0700",   # Maps to com.facebook.sdk:TokenInformationRefreshDateKey
  #         "permissions": ["basic_info","publish_actions"],# Maps to com.facebook.sdk:TokenInformationPermissionsKey
  #         "expires_at": "2013-09-28T19:44:46.520-0700",   # Maps to com.facebook.sdk:TokenInformationExpirationDateKey
  #         "expires": true
  #       }

  it 'registers a user with external authentication' do 
    auth_hash = {
      "provider" => "facebook",
      "uid" => "facebook_uid",
      "info" => {
        "email" => "user@foo.com",
        "name" => "User",
        "dob" => "1911-11-23",
        "gender" => "female"
        },
      "credentials" => {
        "token" => "face_token"
        }
    }
    token = get_conn()
    @payload["auth_hash"] = auth_hash
    response = token.post("#{@endpoint}", @payload)
    result = JSON.parse(response.body, symbolize_names: true)
    user_info = result
    user_info[:access_token].should_not be_nil
    user_info[:user][:email].should == auth_hash["info"]['email']
    user_info[:user][:date_of_birth].should == auth_hash["info"]['dob']
    user_info[:token_type].should == "bearer"    
  end

  it 'logs in an existing user with external authentication' do
    authentication
    user2
    auth_hash = {
      "provider" => authentication.provider,
      "uid" => authentication.uid
    }
    token = get_conn()
    @payload["auth_hash"] = auth_hash
    response = token.post("#{@endpoint}", @payload)
    result = JSON.parse(response.body, symbolize_names: true)
    user_info = result
    user_info[:access_token].should_not be_nil
    user_info[:user][:email].should == user2.email
  end

  it 'creates a guest user if the email/password is not provided' do 
    @payload["guest"] = true
    token = get_conn()
    response = token.post("#{@endpoint}", @payload)
    result = JSON.parse(response.body, symbolize_names: true)
    user_info = result
    user_info[:access_token].should_not be_nil
    user_info[:user][:guest].should == true
  end

  it 'fails to create a new user is password is not confirmed' do 
    token = get_conn()
    @payload["email"] = "test_user@test.co"
    @payload["password"] = "12345678"
    @payload["password_confirmation"] = "12345621"
    response = token.post("#{@endpoint}", @payload)
    result = JSON.parse(response.body, symbolize_names: true)
    result[:error].should == "invalid_resource_owner"
    result[:access_token].should be_nil
  end

  it 'fails to login a user if they dont provide a pass confirm and they are not registered' do 
    token = get_conn()
    @payload["email"] = "user_no_confirm@test.co"
    @payload["password"] = "12345678"
    response = token.post("#{@endpoint}", @payload)
    result = JSON.parse(response.body, symbolize_names: true)
    result[:error].should == "invalid_resource_owner"
    result[:access_token].should be_nil
  end

end