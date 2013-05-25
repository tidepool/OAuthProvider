require 'spec_helper'
require Rails.root + 'app/models/events/user_event.rb'

require 'pry' if Rails.env.test? || Rails.env.development?

describe ResultsCalculator do
  def setup_users
    user_email = 'user@example.com'
    user2_email = 'user2@example.com'
    user = User.where('email = ?', user_email).first
    user2 = User.where('email = ?', user2_email).first
    return user, user2
  end

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

  before(:all) do
    events_json = IO.read(File.expand_path('../../fixtures/test_event_log.json', __FILE__))
    events = JSON.parse(events_json)

    definition = Definition.first
    user, user2 = setup_users
    game = Game.create_by_definition(definition, user)
    record_events_in_redis(game, events)
    @game_id = game.id
  end

  it 'should calculate the results and the profile description' do
    resultsCalc = ResultsCalculator.new 

    game = Game.find(@game_id)
    game.status.should == :not_started.to_s
    resultsCalc.perform(@game_id)

    updated_game = Game.find(@game_id)
    updated_game.status.should == :results_ready.to_s
    updated_game.result.should_not be_nil
    updated_game.result.profile_description.should_not be_nil
    # Below result depends on the exact dataset we fed from test_event_log.json
    updated_game.result.profile_description.name.should == "The Floodlight"
  end
end