require 'spec_helper'
require 'redis'
require Rails.root + 'app/models/events/user_event.rb'

describe ResultsCalculator do
  def record_events_in_redis(game, events)
    UserEvent.cleanup(game.id)

    # Store the events in the Redis
    events.each do |event|
      user_event = UserEvent.new(event)

      # The user events are loaded from a saved file, so update the game id with what we created
      user_event.game_id = game.id
      user_event.record
    end
  end

  let(:guest) { create(:guest) }

  before(:each) do
    definition = Definition.where('name = ?', 'Baseline game').first
    @game  = Game.create_by_definition(definition, guest)

    events_json = IO.read(File.expand_path('../../fixtures/test_event_log.json', __FILE__))
    events = JSON.parse(events_json)
    record_events_in_redis(@game, events)
  end

  it 'should calculate the results and the profile description' do
    resultsCalc = ResultsCalculator.new 
    @game.status.should == :not_started
    resultsCalc.perform(@game.id)

    updated_game = Game.find(@game.id)
    updated_game.status.should == :results_ready.to_s
    updated_game.result.should_not be_nil
    # updated_game.result.profile_description.should_not be_nil
    # # Below result depends on the exact dataset we fed from test_event_log.json
    # updated_game.result.profile_description.name.should == "The Floodlight"
  end

  it 'should cleanup Redis after succesful calculation' do
    key = "game:#{@game.id}"
    $redis.exists(key).should == true
    resultsCalc = ResultsCalculator.new 
    resultsCalc.perform(@game.id)

    $redis.exists(key).should == false
  end
end