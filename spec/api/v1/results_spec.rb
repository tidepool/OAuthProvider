require 'spec_helper'

describe 'Results API' do 
  include AppConnections

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'

    events_json = IO.read(Rails.root.join('lib/analyze/spec/fixtures/aggregate_all.json'))
    @all_events = JSON.parse(events_json)
  end

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:admin) { create(:admin) }
  let(:game) { create(:game, user: user1, status: :not_started) }
  let(:game_no_results) { create(:game, {user: user1, status: :incomplete_results}) }
  let(:game_with_results) { create(:game, {user: user1, status: :results_ready}) }

  let(:reaction_results) { create_list(:result, 10, game: game, user: user1, type: 'ReactionTimeResult')}
  let(:emo_results) { create_list(:result, 5, game: game,  user: user1, type: 'EmoResult')}
  let(:result) { create(:result, game: game_with_results, user: user1) }
 
  let(:daily_results) { create_list(:daily_results, 10, game: game, user: user1, type: 'ReactionTimeResult')}

  it 'starts the results calculation' do 
    ResultsCalculator.stub(:perform_async) do |game_id|
      fake_game = Game.find(game_id)
      fake_game.status = :results_ready
      fake_game.save!
      fake_game.results.create(type: 'Big5Result', score: {'bar' => 'foo'})
      fake_game.results.create(type: 'Holland6Result', score: {'bar' => 'foo'})      
    end
    game.update_event_log(@all_events)

    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/games/#{game.id}/results.json")
    response.status.should == 202
    message = JSON.parse(response.body, :symbolize_names => true)
    message[:status][:state].should == 'pending'
    message[:status][:link].should == "http://example.org#{@endpoint}/users/-/games/#{game.id}/progress"
    message[:data].should be_empty
  end

  it 'declines calculating the results if all events are not received yet' do 
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/games/#{game.id}/results.json")
    response.status.should == 412
    message = JSON.parse(response.body, :symbolize_names => true)
    message[:status][:code].should == 1003
  end

  it 'keeps checking progress' do
    game.update_event_log(@all_events)

    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/games/#{game.id}/results.json")
    message = JSON.parse(response.body, :symbolize_names => true)
    progress_url = "#{message[:status][:link]}.json"
    response = token.get(progress_url)
    response.status.should == 200
    message = JSON.parse(response.body, :symbolize_names => true)
    message[:status][:state].should == 'pending'
  end

  it 'gets the result/show url from progress endpoint for a non-profile calculating game' do
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/games/#{game_with_results.id}/progress.json")
    response.status.should == 200

    expected_url = "http://example.org#{@endpoint}/users/-/games/#{game_with_results.id}/results"

    message = JSON.parse(response.body, :symbolize_names => true)
    message[:status][:link].should == expected_url
    response.headers['Location'].should == expected_url
  end

  it 'gets the error state if results are not calculated' do
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/games/#{game_no_results.id}/progress.json")
    response.status.should == 500
    message = JSON.parse(response.body, :symbolize_names => true)
    message[:status][:code].should == 3001
  end

  it 'shows the results when they are calculated' do
    ResultsCalculator.stub(:perform_async) do |game_id|
      fake_game = Game.find(game_id)
      fake_game.status = :results_ready
      fake_game.save!
      fake_game.results.create(type: 'Big5Result', score: {'bar' => 'foo'}, user_id: fake_game.user.id)
      fake_game.results.create(type: 'Holland6Result', score: {'bar' => 'foo'}, user_id: fake_game.user.id)      
    end
    game.update_event_log(@all_events)

    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/games/#{game.id}/results.json")
    response.status.should == 202
    response = token.get("#{@endpoint}/users/-/games/#{game.id}/results.json")
    response.status.should == 200

    output = JSON.parse(response.body, :symbolize_names => true)
    results = output[:data]
    results.length.should == 2
    results[0][:type].should_not be_nil
    results[1][:type].should_not be_nil
    results[0][:score].should == { :bar => 'foo'}
    results[0][:user_id].should_not be_nil
  end

  it 'gets the results collection of a given type for a given user' do
    reaction_results
    emo_results
    # results = Result.joins(:game).where('games.user_id' => user1.id)
    results = Result.where(user: user1)
    results.length.should == 15
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/results.json?type=ReactionTimeResult")
    response.status.should == 200
    output = JSON.parse(response.body, :symbolize_names => true)
    user_results = output[:data]
    user_results.length.should == 10
  end

  it 'gets the results collection for all types for a given user' do
    reaction_results
    emo_results
    results = Result.where(user: user1)
    results.length.should == 15
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/results.json")
    response.status.should == 200
    output = JSON.parse(response.body, :symbolize_names => true)
    user_results = output[:data]
    user_results.length.should == 15
  end

  it 'shows a result given its id' do 
    game_with_results
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/results/#{result.id}.json")
    response.status.should == 200
    output = JSON.parse(response.body, :symbolize_names => true)
    response_result = output[:data]
    response_result[:game_id].should == game_with_results.id
    response_result[:user_id].should == user1.id
  end

  it 'shows the results in a daily group' do
    daily_results
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/results.json?daily=true")
    response.status.should == 200
    output = JSON.parse(response.body, :symbolize_names => true)
    user_results = output[:data]
  end

  describe 'PersonalityResult' do
    let(:personality_result) { create(:personality_result, game: game, user: user1) }

    it 'shows the results for PersonalityResult as it has some special runtime joins' do 
      personality_result
      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/results.json?type=PersonalityResult")
      response.status.should == 200
      output = JSON.parse(response.body, :symbolize_names => true)
      user_results = output[:data]
      user_results[0].should_not be_nil
      user_results[0][:type].should == 'PersonalityResult'
      user_results[0][:name].should == 'The Brainstorm'
      user_results[0][:one_liner].should_not be_nil
    end
  end

  describe 'SpeedArchetypeResult' do
    let(:speed_archetype_result) { create(:speed_archetype_result, game: game, user: user1) } 

    it 'shows the results for the SpeedArchetypeResult as it has some special runtime joins' do
      speed_archetype_result
      token = get_conn(user1)
      response = token.get("#{@endpoint}/users/-/results.json?type=SpeedArchetypeResult")
      response.status.should == 200
      output = JSON.parse(response.body, :symbolize_names => true)
      user_results = output[:data]
      user_results[0].should_not be_nil
      user_results[0][:type].should == 'SpeedArchetypeResult'
      user_results[0][:speed_archetype].should == 'dog'
      user_results[0][:big5_dimension].should == 'high_openness'
      user_results[0][:description].should_not be_nil
      user_results[0][:bullet_description].class.should == Array
      user_results[0][:display_id].should == 'high_openness_dog'
      user_results[0][:average_time_simple].should == '340'
      user_results[0][:average_time_complex].should == '718'
    end
  end

  describe 'Error and Edge Cases' do
    
  end
end