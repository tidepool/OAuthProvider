require 'spec_helper'
require 'oauth2'
require 'faraday'
require 'pry' if Rails.env.test? || Rails.env.development?

describe 'Game API' do
  def get_conn(user = nil, pass = nil)
    if user.nil? || pass.nil?
      anon_client = Faraday.new do |f|
        f.request :url_encoded
        f.adapter :rack, Rails.application
      end      
    else
      client = OAuth2::Client.new(@app.uid, @app.secret) do |b|
        b.request :url_encoded
        b.adapter :rack, Rails.application
      end   
      client.password.get_token(user, pass)
    end
  end

  def create_game(caller, user)
    definition = Definition.find_or_return_default(nil)
    game = Game.create_by_caller(definition, caller, user)
    game.add_to_user(caller, user)
    game.save!
    game
  end

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
    end

    describe '/api/v1/games' do
      it 'should be able to create an game with user = 0 where 0 means anonymous' do
        anon_client = get_conn
        response = anon_client.post('/api/v1/games.json')
        response.status.should == 200
        game = JSON.parse(response.body)
        game[:user_id.to_s].to_i.should == 0
      end
      
      it 'should not be able to view an game anonymously' do
        game = create_game(@user, @user)
        anon_client = get_conn
        url = "/api/v1/games/#{game.id}.json"
        response = anon_client.get(url)
        response.status.should == 401
      end

      it 'should not be able to get a list of games anonymously' do
        (1..5).each { create_game(@user, @user) }
        anon_client = get_conn
        url = "/api/v1/games.json"
        response = anon_client.get(url)
        response.status.should == 401
      end
    end

    describe '/api/v1/users/:user_id/games' do

    end
  end
  describe 'Authenticated Access' do
    before :all do 
    end

    it 'should be able to get the token' do
      token = get_conn(@user_email, @user_pass)
      token.should_not be_expired
    end

    it 'should be able to deny token for wrong pass' do
      lambda { get_conn(@user_email, 'foo')}.should raise_error(OAuth2::Error)
      lambda { get_conn('foo@foo.com', @user_pass)}.should raise_error(OAuth2::Error)
    end

    describe '/api/v1/games' do
      before :all do
      end

      it 'should be able to create an game' do
        token = get_conn(@user_email, @user_pass)
        response = token.post('/api/v1/games.json')
        response.status.should == 200        
      end

      it 'should be able to create the game with the caller user' do
        token = get_conn(@user_email, @user_pass)
        response = token.post('/api/v1/games.json')
        game = JSON.parse(response.body)
        user_id = game[:user_id.to_s]
        user_id.should == @user.id
      end
      it 'should be able to show an game' do
        game = create_game(@user, @user)
        game.add_to_user(@user,@user)
        game.save!
        
        url = "/api/v1/games/#{game.id}.json"
        token = get_conn(@user_email, @user_pass)
        response = token.get(url)
        response.status.should == 200
        game_result = JSON.parse(response.body, :symbolize_names => true)
        game_result[:id].to_i.should == game.id
      end
    end
    describe '/api/v1/users/:user_id/games' do
      it 'should be able to create an game when the caller and the user are the same' do
        token = get_conn(@user_email, @user_pass)
        user_id = @user.id
        response = token.post("/api/v1/users/#{user_id}/games.json")

        game = JSON.parse(response.body)
        game[:user_id.to_s].to_i.should == @user.id
      end

      it 'should not be able to create an game when the caller and user are not same and caller is not admin' do
        token = get_conn(@user_email, @user_pass)
        user_id = @user2.id
        lambda { token.post("/api/v1/users/#{user_id}/games.json") }.should raise_error(game::UnauthorizedError)
      end

      it 'should be able to create an game when the caller is admin and user is not the same as caller' do
        token = get_conn(@admin_email, @admin_pass)
        user_id = @user.id
        response = token.post("/api/v1/users/#{user_id}/games.json")

        game = JSON.parse(response.body)
        game[:user_id.to_s].to_i.should == @user.id
      end

      it 'should be able to create an anonymous game and attach it to a user if caller is the user' do
        # First create an game as an anonymous non-authenticated user
        anon_client = get_conn 
        response = anon_client.post('/api/v1/games.json')
        response.status.should == 200
        game = JSON.parse(response.body)
        game[:user_id.to_s].to_i.should == 0

        # Now sign in and add that game to your new user_id
        game_id = game[:id.to_s]
        attributes = { :user_id => @user.id }
        token = get_conn(@user_email, @user_pass)
        response = token.put("/api/v1/users/#{@user.id}/games/#{game_id}.json", 
                    :body => {:game => attributes})
        response.status.should == 200
        game = JSON.parse(response.body)
        game[:user_id.to_s].to_i.should == @user.id
      end

      it 'should be able to create an anonymous game and attach it to any user if caller is an admin user' do
        # First create an game as an anonymous non-authenticated user
        anon_client = get_conn
        response = anon_client.post('/api/v1/games.json')
        response.status.should == 200
        game = JSON.parse(response.body)
        game[:user_id.to_s].to_i.should == 0

        # Now sign in and add that game to your new user_id
        game_id = game[:id.to_s]
        attributes = { :user_id => @user.id }
        token = get_conn(@admin_email, @admin_pass)
        response = token.put("/api/v1/users/#{@user.id}/games/#{game_id}.json", 
                    :body => {:game => attributes})
        response.status.should == 200
        game = JSON.parse(response.body)
        game[:user_id.to_s].to_i.should == @user.id
      end

      it 'should not be able to create an anonymous game and attach it to a user if caller is not the same user or admin' do
        # First create an game as an anonymous non-authenticated user
        anon_client = get_conn
        response = anon_client.post('/api/v1/games.json')
        response.status.should == 200
        game = JSON.parse(response.body, :symbolize_names => true)
        game[:user_id].to_i.should == 0

        # Now sign in as a non-admin user and try to add that game to another user_id
        game_id = game[:id]
        attributes = { :user_id => @user.id }
        token = get_conn(@user2_email, @user2_pass)
        lambda {token.put("/api/v1/users/#{@user.id}/games/#{game_id}.json", 
                    :body => {:game => attributes})}.should raise_error(game::UnauthorizedError)

      end

      it 'should be able to show an game' do
        game = create_game(@user, @user)
        game.add_to_user(@user,@user)
        game.save!

        url = "/api/v1/users/#{@user.id}/games/#{game.id}.json"
        token = get_conn(@user_email, @user_pass)
        response = token.get(url)
        response.status.should == 200
        game_result = JSON.parse(response.body, :symbolize_names => true)
        game_result[:id].to_i.should == game.id
      end

      it 'should be able to get a list of users own games for the user' do
        (1..5).each do
          game = create_game(@user2, @user2)
          game.add_to_user(@user2, @user2)
          game.save!
        end
   
        url = "/api/v1/users/#{@user2.id}/games.json"
        token = get_conn(@user2_email, @user2_pass)
        response = token.get(url)
        response.status.should == 200
        games = JSON.parse(response.body, :symbolize_names => true)
        games[:games].length.should >= 5
      end

    end
  end
end
