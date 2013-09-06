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
  let(:game_with_results) { create(:game, user: user1) }
  let(:emo_result) { create(:result, user: user1, game: game_with_results, type: 'EmoResult') }
  let(:reaction_result) { create(:result, user: user1, game: game_with_results, type: 'ReactionTimeResult')}

  it 'creates a game when user_id is - for the caller' do
    token = get_conn(user1)
    response = token.post("#{@endpoint}/users/-/games.json",
      { body: { def_id: 'baseline' } })
    response.status.should == 200        
    result = JSON.parse(response.body, symbolize_names: true)
    game_result = result[:data]
    game_result[:user_id].should == user1.id
  end

  it 'creates a game which has the user_id in the URI' do
    token = get_conn(user1)
    response = token.post("#{@endpoint}/users/#{user1.id}/games.json",
      { body: { def_id: 'baseline' } })
    response.status.should == 200
    result = JSON.parse(response.body, symbolize_names: true)
    game_result = result[:data]
    game_result[:user_id].should == user1.id
  end

  it 'creates a game with a def_id in the parameters' do
    token = get_conn(user1)
    response = token.post("#{@endpoint}/users/#{user1.id}/games.json", 
      { body: { def_id: 'baseline' } })
    response.status.should == 200
    result = JSON.parse(response.body, symbolize_names: true)
    game_result = result[:data]
    game_result[:name].should == 'baseline'
  end

  it 'creates a game with a definition that is same as the game in the same_as parameter' do
    token = get_conn(user1)
    definition = game.definition
    response = token.post("#{@endpoint}/users/#{user1.id}/games.json",
      { body: { same_as: game.id } })
    response.status.should == 200
    result = JSON.parse(response.body, symbolize_names: true)
    game_result = result[:data]
    game_result[:name].should == definition.unique_name
  end

  it 'records the ip of the caller when the game is created' do
    token = get_conn(user1)
    response = token.post("#{@endpoint}/users/#{user1.id}/games.json", 
      { body: { def_id: 'baseline' } })
    response.status.should == 200
    result = JSON.parse(response.body, symbolize_names: true)
    game_result = result[:data]
    game_result[:id].should_not be_nil

    newGame = Game.find(game_result[:id])
    newGame.calling_ip.should_not be_nil
  end

  it 'shows an existing game' do
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/#{user1.id}/games/#{game.id}.json")
    response.status.should == 200
    result = JSON.parse(response.body, symbolize_names: true)
    game_result = result[:data]
    game_result[:id].to_i.should == game.id
  end

  it 'shows an existing game with its results' do 
    emo_result
    reaction_result
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/#{user1.id}/games/#{game_with_results.id}.json")
    response.status.should == 200
    result = JSON.parse(response.body, symbolize_names: true)
    game_result = result[:data]

  end

  it 'doesnot allow non-admins to create games for other users' do
    token = get_conn(user1)
    response = token.post("#{@endpoint}/users/#{user2.id}/games.json") 
    response.status.should == 401
    result = JSON.parse(response.body, symbolize_names: true)
    result[:status][:code].should == 1000                       
  end

  it 'allows admins create a game for other users' do
    token = get_conn(admin)
    response = token.post("#{@endpoint}/users/#{user2.id}/games.json",
      { body: { def_id: 'baseline' } })
    result = JSON.parse(response.body, symbolize_names: true)
    game_result = result[:data]
    game_result[:user_id].to_i.should == user2.id
  end

  it 'gets a list of users games' do 
    token = get_conn(user2)
    expected_games = game_list 
    response = token.get("#{@endpoint}/users/#{user2.id}/games.json")
    result = JSON.parse(response.body, symbolize_names: true)
    games = result[:data]
    games.length.should == game_list.length
    games[0][:user_id].to_i.should == user2.id
  end

  it 'gets the latest game of the user' do
    token = get_conn(user2)
    sorted_games = (game_list.sort { | x, y | x.date_taken <=> y.date_taken }).reverse
    response = token.get("#{@endpoint}/users/#{user2.id}/games/latest.json")
    result = JSON.parse(response.body, symbolize_names: true)
    latest_game = result[:data]
    latest_game[:id].should == sorted_games[0].id
  end

  it 'deletes the game' do
    token = get_conn(user1)
    game_id = game_to_be_deleted.id
    response = token.delete("#{@endpoint}/users/#{user1.id}/games/#{game_id}.json")
    lambda { Game.find(game_id) }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it 'updates to the the stage_completed' do
    token = get_conn(user1)
    game_params = { stage_completed: 1 }
    response = token.put("#{@endpoint}/users/#{user1.id}/games/#{game.id}.json",
        { body: { game: game_params } })
    result = JSON.parse(response.body, symbolize_names: true)
    updated_game = result[:data]
    updated_game[:stage_completed].should == 1
  end

  describe 'Updating the event_log' do
    before :each do
      @event = {
        "event_type" => "image_rank",
        "stage" => 2,
        "events" =>  [
          {"time" => 1360194798295,"event" => "level_started","data" => [{"url" => "assets/devtest_images/F1a.jpg","elements" => "color,human,male,man_made,movement,nature,pair,reflection,texture,whole","image_id" => "F1a","rank" => -1},{"url" => "assets/devtest_images/F1b.jpg","elements" => "color,male,man_made,pair,reflection","image_id" => "F1b","rank" => -1},{"url" => "assets/devtest_images/F1c.jpg","elements" => "color,human,human_eyes,male,man_made,movement,negative_space,pair,reflection,texture","image_id" => "F1c","rank" => -1},{"url" => "assets/devtest_images/F1d.jpg","elements" => "color,happy,human,human_eyes,nature,shading,texture,vista,whole","image_id" => "F1d","rank" => -1},{"url" => "assets/devtest_images/F1e.jpg","elements" => "color,human,male,man_made,movement,pair,reflection,shading,whole","image_id" => "F1e","rank" => -1}]},
          {"time" => 1360194799677,"index" => 0, "event" => "start_move"},
          {"time" => 1360194800133,"index" => 0, "rank" => "0","event" => "end_move"},
          {"time" => 1360194801706,"index" => 2, "event" => "start_move"},
          {"time" => 1360194802233,"index" => 2, "rank" => "2","event" => "end_move"},
          {"time" => 1360194803821,"index" => 4, "event" => "start_move"},
          {"time" => 1360194804382,"index" => 4, "rank" => "1","event" => "end_move"},
          {"time" => 1360194805788,"index" => 1, "event" => "start_move"},
          {"time" => 1360194811482,"index" => 1, "rank" => "4","event" => "end_move"},
          {"time" => 1360194813884,"index" => 3, "event" => "start_move"},
          {"time" => 1360194815866,"index" => 3, "rank" => "3","event" => "end_move"},
          {"time" => 1360194815867,"event" => "level_completed"},
          {"time" => 1360194815868,"event" => "level_summary", "final_rank" => [0,4,2,3,1]}
        ]
      }
    end

    it 'updates the event log of a game with a single stage' do
      token = get_conn(user1)
      game.user_id.should == user1.id
      response = token.put("#{@endpoint}/users/#{user1.id}/games/#{game.id}/event_log.json",
        { body: { event_log: @event } })
      result = JSON.parse(response.body, symbolize_names: true)
      response.status.should == 200
      result[:status][:state].should == 'event_log_updated'

      updated_game = Game.find(game.id)
      updated_game.event_log.should_not be_empty
      updated_game.event_log["2"]["event_type"].should == "image_rank"
    end

    it 'updates the event log for a real recorded snoozer events' do 
      events_json = IO.read(Rails.root.join('lib/analyze/spec/fixtures/realdata_snoozer.json'))
      all_events = JSON.parse(events_json)

      token = get_conn(user1)
      game.user_id.should == user1.id
      response = token.put("#{@endpoint}/users/#{user1.id}/games/#{game.id}/event_log.json",
        { body: { event_log: all_events } })
      result = JSON.parse(response.body, symbolize_names: true)
      response.status.should == 200
      result[:status][:state].should == 'event_log_updated'

      updated_game = Game.find(game.id)
      updated_game.event_log.should_not be_empty
      updated_game.event_log["0"]["event_type"].should == "snoozer"

    end

    it 'updates the event log of a game with an array of stages' do
      events_json = IO.read(Rails.root.join('lib/analyze/spec/fixtures/aggregate_all.json'))
      all_events = JSON.parse(events_json)

      token = get_conn(user1)
      game.user_id.should == user1.id
      response = token.put("#{@endpoint}/users/#{user1.id}/games/#{game.id}/event_log.json",
        { body: { event_log: all_events } })

      result = JSON.parse(response.body, symbolize_names: true)
      response.status.should == 200
      result[:status][:state].should == 'event_log_updated'

      updated_game = Game.find(game.id)
      updated_game.event_log.should_not be_empty
      updated_game.event_log.length.should == all_events.length
    end

    it 'receives an error if the event does not validate' do 
      @event["events"].delete_at(0)

      token = get_conn(user1)
      game.user_id.should == user1.id
      response = token.put("#{@endpoint}/users/#{user1.id}/games/#{game.id}/event_log.json",
        { body: { event_log: @event } })
      result = JSON.parse(response.body, symbolize_names: true)
      response.status.should == 409
      result[:status][:code].should == 5000
      updated_game = Game.find(game.id)
      updated_game.event_log.should be_nil
    end
  end

  describe 'Error and Edge Cases' do
    it 'does not let API to update status directly' do 
      token = get_conn(user1)
      game_params = { status: :incomplete_results }
      response = token.put("#{@endpoint}/users/#{user1.id}/games/#{game.id}.json",
          { body: { game: game_params } })
      result = JSON.parse(response.body, symbolize_names: true)
      updated_game = result[:data]
      updated_game[:status].should == 'not_started'
    end

    it 'returns an error if def_id is omitted during creation' do 
      token = get_conn(user1)
      response = token.post("#{@endpoint}/users/#{user1.id}/games.json")
      response.status.should == 422
      result = JSON.parse(response.body, symbolize_names: true)
      game_result = result[:status]
      game_result[:code].should == 1002
    end

    it 'returns an error def_id cannot be found during creation' do
      token = get_conn(user1)
      response = token.post("#{@endpoint}/users/#{user1.id}/games.json", 
        { body: { def_id: 'foobar' } })
      response.status.should == 404
      result = JSON.parse(response.body, symbolize_names: true)
      game_result = result[:status]
      game_result[:code].should == 1001
    end

  end
end
