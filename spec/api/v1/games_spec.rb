require 'spec_helper'

describe 'Game API' do
  include AppConnections

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:admin) { create(:admin) }
  let(:game) { create(:game, user: user1) }
  let(:game_list) { create_list(:game, 10, user: user2) }
  let(:game_to_be_deleted) { create(:game, user: user1) }

  it 'creates a game when user_id is - for the caller' do
    token = get_conn(user1)
    response = token.post("#{@endpoint}/users/-/games.json")
    response.status.should == 200        
    game_result = JSON.parse(response.body, symbolize_names: true)
    game_result[:user_id].should == user1.id
  end

  it 'creates a game which has the user_id in the URI' do
    token = get_conn(user1)
    response = token.post("#{@endpoint}/users/#{user1.id}/games.json")
    response.status.should == 200
    game_result = JSON.parse(response.body, symbolize_names: true)
    game_result[:user_id].should == user1.id
  end

  it 'creates a game with a def_id in the parameters' do
    token = get_conn(user1)
    response = token.post("#{@endpoint}/users/#{user1.id}/games.json", 
      { body: { def_id: 'baseline' } })
    response.status.should == 200
    game_result = JSON.parse(response.body, symbolize_names: true)
    game_result[:definition][:unique_name].should == 'baseline'
  end

  it 'records the ip of the caller when the game is created' do
    token = get_conn(user1)
    response = token.post("#{@endpoint}/users/#{user1.id}/games.json", 
      { body: { def_id: 'baseline' } })
    response.status.should == 200
    game_result = JSON.parse(response.body, symbolize_names: true)
    game_result[:id].should_not be_nil

    newGame = Game.find(game_result[:id])
    newGame.calling_ip.should_not be_nil
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
    latest_game = JSON.parse(response.body, symbolize_names: true)
    latest_game[:id].should == sorted_games[0].id
  end

  it 'deletes the game' do
    token = get_conn(user1)
    game_id = game_to_be_deleted.id
    response = token.delete("#{@endpoint}/users/#{user1.id}/games/#{game_id}.json")
    lambda { Game.find(game_id) }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it 'updates the stage_completed but the status remains the same' do
    token = get_conn(user1)
    game_params = { stage_completed: 2, status: 'completed'}
    response = token.put("#{@endpoint}/users/#{user1.id}/games/#{game.id}.json",
        { body: { game: game_params } })
    updated_game = JSON.parse(response.body, symbolize_names: true)
    updated_game[:stage_completed].should == 2
    updated_game[:status].should == 'not_started'
  end

  pending 'gets the latest game with profile calculation' 

  describe 'Error and Edge Cases' do

  end
end
