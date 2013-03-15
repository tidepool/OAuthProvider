require 'spec_helper'
require 'oauth2'
require 'pry' if Rails.env.test? || Rails.env.development?


describe 'Assessment API' do
  before :all do
    @user_email = 'user@example.com'
    @user_pass = 'tidepool'

    @user = User.where('email = ?',  @user_email).first

    if @user.nil?
      @user = User.create! :email => @user_email, :password => @user_pass, :password_confirmation => @user_pass
    end

    @app = Doorkeeper::Application.where('name = ?', 'tidepool_test').first_or_create do |app|
      app.name = 'tidepool_test'
      app.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
    end
    @app.save!
  end

  describe 'Anonymous Access' do
    before :all do
      
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

    describe 'Assessment API CRUD' do
      before :all do
        @token = @client.password.get_token(@user_email, @user_pass)
      end

      it 'should be able to create an assessment' do
        response = @token.post('/api/v1/assessments.json')
        response.status.should == 200        
      end

      it 'should be able to assign a user to the assessment' do
        response = @token.post('/api/v1/assessments.json')
        assessment = JSON.parse(response.body)
        user_id = assessment[:user_id.to_s]
        user_id.should_not be_nil

        user = User.find(user_id)
        user.email.should == @user_email
      end
      it 'should be able to ' do
        
      end
    end
  end
end
