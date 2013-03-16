require 'spec_helper'
require 'oauth2'
require 'faraday'
require 'pry' if Rails.env.test? || Rails.env.development?

describe 'Assessment API' do
  before :all do
    @user_email = 'user@example.com'
    @user_pass = 'tidepool'
    @user2_email = 'user2@example.com'
    @user2_pass = 'tidepool'
    @admin_email = 'admin@example.com'
    @admin_pass = 'tidepool'

    @user = User.where('email = ?', @user_email).first
    @user2 = User.where('email = ?', @user2_email).first
    @admin = User.where('email = ?', @admin_email).first

    @app = Doorkeeper::Application.where('name = ?', 'tidepool_test').first_or_create do |app|
      app.name = 'tidepool_test'
      app.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
    end
    @app.save!
  end

  describe 'Anonymous Access' do
    before :all do
      @anon_client = Faraday.new do |f|
        f.request :url_encoded
        f.adapter :rack, Rails.application
      end      
    end

    describe '/api/v1/assessments' do
      it 'should be able to create an assessment with user = 0' do
        response = @anon_client.post('/api/v1/assessments.json')
        response.status.should == 200
        assessment = JSON.parse(response.body)
        assessment[:user_id.to_s].to_i.should == 0
      end

    end

    describe '/api/v1/users/:user_id/assessments' do

    end
  end
  describe 'Authenticated Access' do
    before :all do 
      @client = OAuth2::Client.new(@app.uid, @app.secret) do |b|
        b.request :url_encoded
        b.adapter :rack, Rails.application
      end   
    end

    it 'should be able to get the token' do
      token = @client.password.get_token(@user_email, @user_pass)

      token.should_not be_expired
    end

    it 'should be able to deny token for wrong pass' do
      lambda { @client.password.get_token(@user_email, 'foo')}.should raise_error(OAuth2::Error)
      lambda { @client.password.get_token('foo@foo.com', @user_pass)}.should raise_error(OAuth2::Error)
    end

    describe '/api/v1/assessments' do
      before :all do
        @token = @client.password.get_token(@user_email, @user_pass)
      end

      it 'should be able to create an assessment' do
        response = @token.post('/api/v1/assessments.json')
        response.status.should == 200        
      end

      it 'should be able to create the assessment with the caller user' do
        response = @token.post('/api/v1/assessments.json')
        assessment = JSON.parse(response.body)
        user_id = assessment[:user_id.to_s]
        user_id.should == @user.id
      end
      it 'should be able to ' do

      end
    end
    describe '/api/v1/users/:user_id/assessments' do
      it 'should be able to create an assessment when the caller and the user are the same' do
        @token = @client.password.get_token(@user_email, @user_pass)
        user_id = @user.id
        response = @token.post("/api/v1/users/#{user_id}/assessments.json")

        assessment = JSON.parse(response.body)
        assessment[:user_id.to_s].to_i.should == @user.id
      end

      it 'should not be able to create an assessment when the caller and user are not same and caller is not admin' do
        @token = @client.password.get_token(@user_email, @user_pass)
        user_id = @user2.id
        lambda { @token.post("/api/v1/users/#{user_id}/assessments.json") }.should raise_error(Assessment::UnauthorizedError)
      end

      it 'should be able to create an assessment when the caller is admin and user is not the same as caller' do
        @token = @client.password.get_token(@admin_email, @admin_pass)
        user_id = @user.id
        response = @token.post("/api/v1/users/#{user_id}/assessments.json")

        assessment = JSON.parse(response.body)
        assessment[:user_id.to_s].to_i.should == @user.id
      end

      it 'should be able to create an anonymous assessment and attach it to a user if caller is the user' do
        # First create an assessment as an anonymous non-authenticated user
        anon_client = Faraday.new do |f|
          f.request :url_encoded
          f.adapter :rack, Rails.application
        end      
        response = anon_client.post('/api/v1/assessments.json')
        response.status.should == 200
        assessment = JSON.parse(response.body)
        assessment[:user_id.to_s].to_i.should == 0

        # Now sign in and add that assessment to your new user_id
        assessment_id = assessment[:id.to_s]
        attributes = { :user_id => @user.id }
        @token = @client.password.get_token(@user_email, @user_pass)
        response = @token.put("/api/v1/users/#{@user.id}/assessments/#{assessment_id}.json", 
                    :body => {:assessment => attributes})
        response.status.should == 200
        assessment = JSON.parse(response.body)
        assessment[:user_id.to_s].to_i.should == @user.id
      end

      it 'should be able to create an anonymous assessment and attach it to any user if caller is an admin user' do
        # First create an assessment as an anonymous non-authenticated user
        anon_client = Faraday.new do |f|
          f.request :url_encoded
          f.adapter :rack, Rails.application
        end      
        response = anon_client.post('/api/v1/assessments.json')
        response.status.should == 200
        assessment = JSON.parse(response.body)
        assessment[:user_id.to_s].to_i.should == 0

        # Now sign in and add that assessment to your new user_id
        assessment_id = assessment[:id.to_s]
        attributes = { :user_id => @user.id }
        @token = @client.password.get_token(@admin_email, @admin_pass)
        response = @token.put("/api/v1/users/#{@user.id}/assessments/#{assessment_id}.json", 
                    :body => {:assessment => attributes})
        response.status.should == 200
        assessment = JSON.parse(response.body)
        assessment[:user_id.to_s].to_i.should == @user.id
      end

      it 'should not be able to create an anonymous assessment and attach it to a user if caller is not the same user or admin' do
        # First create an assessment as an anonymous non-authenticated user
        anon_client = Faraday.new do |f|
          f.request :url_encoded
          f.adapter :rack, Rails.application
        end      
        response = anon_client.post('/api/v1/assessments.json')
        response.status.should == 200
        assessment = JSON.parse(response.body)
        assessment[:user_id.to_s].to_i.should == 0

        # Now sign in as a non-admin user and try to add that assessment to another user_id
        assessment_id = assessment[:id.to_s]
        attributes = { :user_id => @user.id }
        @token = @client.password.get_token(@user2_email, @user2_pass)
        lambda {@token.put("/api/v1/users/#{@user.id}/assessments/#{assessment_id}.json", 
                    :body => {:assessment => attributes})}.should raise_error(Assessment::UnauthorizedError)

      end

    end
  end
end
