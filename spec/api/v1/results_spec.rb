require 'spec_helper'

describe 'Results API' do 
  include AppConnections

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:admin) { create(:admin) }
  let(:profile_def) { create(:profile_game)}
  let(:non_profile_def) { create(:other_game)}
  let(:game) { create(:game, user: user1, status: :in_progress) }
  let(:game_no_results) { create(:game, {user: user1, status: :no_results}) }
  let(:profile_game_with_results) { create(:game, {user: user1, status: :results_ready, definition: profile_def}) }
  let(:non_profile_game_with_results) { create(:game, {user: user1, status: :results_ready, definition: non_profile_def}) }
  let(:result) { create(:result, game: non_profile_game_with_results) } 

 
  it 'starts the results calculation' do 
    ResultsCalculator.stub(:performAsync) do |game_id|
      fake_game = Game.find(game_id)
      fake_game.status = :results_ready
      fake_game.save!
    end

    token = get_conn(user1)
    response = token.post("#{@endpoint}/users/-/games/#{game.id}/result.json")
    response.status.should == 202
    message = JSON.parse(response.body, :symbolize_names => true)
    message[:status][:state].should == 'pending'
    message[:status][:link].should == "http://example.org#{@endpoint}/users/-/games/#{game.id}/progress"
  end

  it 'keeps checking progress' do
    ResultsCalculator.stub(:performAsync) do |game_id|
      fake_game = Game.find(game_id)
      fake_game.status = :completed
      fake_game.save!
    end

    token = get_conn(user1)
    response = token.post("#{@endpoint}/users/-/games/#{game.id}/result.json")
    message = JSON.parse(response.body, :symbolize_names => true)
    progress_url = "#{message[:status][:link]}.json"
    response = token.get(progress_url)
    response.status.should == 200
    message = JSON.parse(response.body, :symbolize_names => true)
    message[:status][:state].should == 'pending'
  end

  it 'gets the result/show url from progress endpoint for a non-profile calculating game' do
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/games/#{non_profile_game_with_results.id}/progress.json")
    response.status.should == 200

    expected_url = "http://example.org#{@endpoint}/users/-/games/#{non_profile_game_with_results.id}/result"

    message = JSON.parse(response.body, :symbolize_names => true)
    message[:status][:link].should == expected_url
    response.headers['Location'].should == expected_url
  end

  it 'gets user/personality url from progress endpoint for a profile calculating game' do
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/games/#{profile_game_with_results.id}/progress.json")
    response.status.should == 200
    expected_url = "http://example.org#{@endpoint}/users/-/personality"
    message = JSON.parse(response.body, :symbolize_names => true)
    message[:status][:link].should == expected_url
    response.headers['Location'].should == expected_url
  end


  it 'gets the error state if results are not calculated' do
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/games/#{game_no_results.id}/progress.json")
    response.status.should == 200
    message = JSON.parse(response.body, :symbolize_names => true)
    message[:status][:state].should == 'error'
    message[:status][:link].should == "http://example.org#{@endpoint}/users/-/games/#{game_no_results.id}/result"
  end

  it 'shows the results when they are calculated' do
    concrete_result = result # We need this otherwise Result is not created by Factory Girl
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/games/#{non_profile_game_with_results.id}/result.json")
    response.status.should == 200
    results = JSON.parse(response.body, :symbolize_names => true)
    # results[:status][:state].should == :done.to_s
    intermediate_results = JSON.parse(results[:intermediate_results])
    intermediate_results['message'].should == 'Hello World'
    aggregate_results = JSON.parse(results[:aggregate_results])
    aggregate_results['message'].should == 'Hello Aggregates'
  end

  describe 'Error and Edge Cases' do
    
  end
end