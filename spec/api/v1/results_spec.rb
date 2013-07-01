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
  # let(:profile_def) { create(:profile_game)}
  # let(:non_profile_def) { create(:other_game)}
  let(:game) { create(:game, user: user1, status: :in_progress) }
  let(:game_no_results) { create(:game, {user: user1, status: :no_results}) }
  let(:game_with_results) { create(:game, {user: user1, status: :results_ready}) }
  # let(:non_profile_game_with_results) { create(:game, {user: user1, status: :results_ready, definition: non_profile_def}) }
  # let(:result) { create(:result, game: non_profile_game_with_results) } 

  let(:reaction_results) { create_list(:result, 10, game: game, user: user1, result_type: 'reaction_time')}
  let(:emo_results) { create_list(:result, 5, game: game,  user: user1, result_type: 'emo')}
 
  it 'starts the results calculation' do 
    ResultsCalculator.stub(:perform_async) do |game_id|
      fake_game = Game.find(game_id)
      fake_game.status = :results_ready
      fake_game.save!
      fake_game.results.create(result_type: 'big5', score: {'bar' => 'foo'})
      fake_game.results.create(result_type: 'holland6', score: {'bar' => 'foo'})      
    end

    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/games/#{game.id}/results.json")
    response.status.should == 202
    message = JSON.parse(response.body, :symbolize_names => true)
    message[:status][:state].should == 'pending'
    message[:status][:link].should == "http://example.org#{@endpoint}/users/-/games/#{game.id}/progress"
  end

  it 'keeps checking progress' do
    # ResultsCalculator.stub(:perform_async) do |game_id|
    #   fake_game = Game.find(game_id)
    #   fake_game.status = :completed
    #   fake_game.save!
    # end

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

  # it 'gets user/personality url from progress endpoint for a profile calculating game' do
  #   token = get_conn(user1)
  #   response = token.get("#{@endpoint}/users/-/games/#{profile_game_with_results.id}/progress.json")
  #   response.status.should == 200
  #   expected_url = "http://example.org#{@endpoint}/users/-/personality"
  #   message = JSON.parse(response.body, :symbolize_names => true)
  #   message[:status][:link].should == expected_url
  #   response.headers['Location'].should == expected_url
  # end

  it 'gets the error state if results are not calculated' do
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/games/#{game_no_results.id}/progress.json")
    response.status.should == 200
    message = JSON.parse(response.body, :symbolize_names => true)
    message[:status][:state].should == 'error'
    message[:status][:link].should == "http://example.org#{@endpoint}/users/-/games/#{game_no_results.id}/results"
  end

  it 'shows the results when they are calculated' do
    ResultsCalculator.stub(:perform_async) do |game_id|
      fake_game = Game.find(game_id)
      fake_game.status = :results_ready
      fake_game.save!
      fake_game.results.create(result_type: 'big5', score: {'bar' => 'foo'}, user_id: fake_game.user.id)
      fake_game.results.create(result_type: 'holland6', score: {'bar' => 'foo'}, user_id: fake_game.user.id)      
    end

    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/games/#{game.id}/results.json")
    response.status.should == 202
    response = token.get("#{@endpoint}/users/-/games/#{game.id}/results.json")
    response.status.should == 200

    response = JSON.parse(response.body, :symbolize_names => true)
    response[:results].length.should == 2
    response[:results][0][:result_type].should_not be_nil
    response[:results][1][:result_type].should_not be_nil
    response[:results][0][:score].should == { :bar => 'foo'}
    response[:results][0][:user_id].should_not be_nil
  end

  it 'gets the results collection for a given user' do
    reaction_results
    emo_results
    # results = Result.joins(:game).where('games.user_id' => user1.id)
    results = Result.where(user: user1)
    results.length.should == 15
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/results.json?type=reaction_time")
    response.status.should == 200
    user_results = JSON.parse(response.body, :symbolize_names => true)
    user_results[:results].length.should == 10
  end

  describe 'Error and Edge Cases' do
    
  end
end