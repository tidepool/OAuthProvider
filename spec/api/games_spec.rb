require 'spec_helper'
require 'oauth2'
require 'faraday'
require 'pry' if Rails.env.test? || Rails.env.development?

describe 'Game API' do
  def get_conn(user, password = '12345678')
    if user.nil?
      anon_client = Faraday.new do |f|
        f.request :url_encoded
        f.adapter :rack, Rails.application
      end      
    else
      client = OAuth2::Client.new(@app.uid, @app.secret) do |b|
        b.request :url_encoded
        b.adapter :rack, Rails.application
      end   
      client.password.get_token(user.email, password)
    end
  end

  before :all do
    # @user1 = User.where('email = ?', 'user@example.com').first
    # @user2 = User.where('email = ?', 'user2@example.com').first
    # @admin = User.where('email = ?', 'admin@example.com').first

    @app = Doorkeeper::Application.where('name = ?', 'tidepool_test').first_or_create do |app|
      app.name = 'tidepool_test'
      app.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
    end
    @app.save!

    @endpoint = '/api/v1'
  end

  describe 'Anonymous Access' do
    # describe '/api/v1/games' do
    #   it 'should be able to create an game with user = 0 where 0 means anonymous' do
    #     anon_client = get_conn
    #     response = anon_client.post('/api/v1/games.json')
    #     response.status.should == 200
    #     game = JSON.parse(response.body)
    #     game[:user_id.to_s].to_i.should == 0
    #   end
      
    #   it 'should not be able to view an game anonymously' do
    #     game = create_game(@user, @user)
    #     anon_client = get_conn
    #     url = "/api/v1/games/#{game.id}.json"
    #     response = anon_client.get(url)
    #     response.status.should == 401
    #   end

    #   it 'should not be able to get a list of games anonymously' do
    #     (1..5).each { create_game(@user, @user) }
    #     anon_client = get_conn
    #     url = "/api/v1/games.json"
    #     response = anon_client.get(url)
    #     response.status.should == 401
    #   end
    # end

    # describe '/api/v1/users/:user_id/games' do

    # end
  end
  describe 'Authenticated Access' do
    let(:user1) {create(:user)}
    let(:user2) {create(:user)}
    let(:admin) {create(:admin)}
    let(:game) {create(:game, user: user1)}
    let(:game_list) {create_list(:game, 10, user: user2)}

    describe 'Authentication works' do 
      it 'gets the token' do
        token = get_conn(user1)
        token.should_not be_expired
      end

      it 'denies token for wrong pass' do
        lambda { get_conn(user1, 'foo')}.should raise_error(OAuth2::Error)
      end
    end

    describe "#{@endpoint}/users/:user_id/games" do
      it 'creates a game when user_id is - for the caller' do
        token = get_conn(user1)
        response = token.post("#{@endpoint}/users/-/games.json")
        response.status.should == 200        
      end

      it 'creates a game when a user_id is specified in URI' do 
        token = get_conn(user1)
        response = token.post("#{@endpoint}/users/#{user1.id}/games.json")
        response.status.should == 200
      end

      it 'creates a game which has the user_id in the URI' do
        token = get_conn(user1)
        response = token.post("#{@endpoint}/users/#{user1.id}/games.json")
        game = JSON.parse(response.body, symbolize_names: true)
        user_id = game[:user_id]
        user_id.should == user1.id
      end

      it 'shows an existing game' do
        token = get_conn(user1)
        response = token.get("#{@endpoint}/users/#{user1.id}/games/#{game.id}.json")
        response.status.should == 200
        game_result = JSON.parse(response.body, symbolize_names: true)
        game_result[:id].to_i.should == game.id
      end

      it 'doesnot allow non-admins to create games for other users' do
        token = get_conn(user1)
        lambda { token.post("#{@endpoint}/users/#{user2.id}/games.json") }.should raise_error(Api::V1::UnauthorizedError)
      end

      it 'allows admins create a game for other users' do
        token = get_conn(admin)
        response = token.post("#{@endpoint}/users/#{user2.id}/games.json")
        game = JSON.parse(response.body, symbolize_names: true)
        game[:user_id].to_i.should == user2.id
      end

      it 'gets a list of users games' do 
        token = get_conn(user2)
        expected_games = game_list 
        response = token.get("#{@endpoint}/users/#{user2.id}/games.json")
        games = JSON.parse(response.body, symbolize_names: true)
        games[:games].length.should == game_list.length
        games[:games][0][:user_id].to_i.should == user2.id
      end

      it 'gets the latest game of the user' do
        token = get_conn(user2)
        sorted_games = (game_list.sort { | x, y | x.date_taken <=> y.date_taken }).reverse
        response = token.get("#{@endpoint}/users/#{user2.id}/games/latest.json")
        game = JSON.parse(response.body, symbolize_names: true)
        game[:id].should == sorted_games[0].id
      end

      pending 'gets the latest game with profile calculation' 
    end
  end
end
