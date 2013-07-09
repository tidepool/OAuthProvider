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

  describe 'Happy Path: ' do
    let(:guest) { create(:guest) }

    before(:each) do
      definition = Definition.where(unique_name: 'baseline').first
      @game  = Game.create_by_definition(definition, guest)

      events_json = IO.read(File.expand_path('../../fixtures/test_event_log.json', __FILE__))
      events = JSON.parse(events_json)
      record_events_in_redis(@game, events)
    end

    after(:each) do
      UserEvent.cleanup(@game.id)
    end

    it 'calculates the results and the profile description' do
      resultsCalc = ResultsCalculator.new 
      @game.status.should == :not_started
      resultsCalc.perform(@game.id)

      updated_game = Game.find(@game.id)
      updated_game.status.should == :results_ready.to_s
      updated_game.results.length.should == 3

      # Below result depends on the exact dataset we fed from test_event_log.json
      guest.personality.should_not be_nil    
      guest.personality.profile_description.name.should_not be_nil
      guest.personality.big5_dimension.should_not be_nil
      guest.personality.holland6_dimension.should_not be_nil
      guest.personality.big5_low.should_not be_nil
      guest.personality.big5_high.should_not be_nil
      guest.personality.holland6_score.should_not be_nil
      guest.personality.big5_score.should_not be_nil

      # guest.personality.profile_description.name.should == 'The Charger'
      # guest.personality.big5_dimension.should == 'low_conscientiousness'
      # guest.personality.profile_description.name.should == 'The Shelter'
      # guest.personality.big5_dimension.should == 'high_neuroticism'
      # guest.personality.holland6_dimension.should == 'social'
      # guest.personality.big5_low.should == 'conscientiousness'
      # guest.personality.big5_high.should == 'neuroticism'
    end

    it 'cleans up Redis' do
      key = "game:#{@game.id}"
      $redis.exists(key).should == true
      resultsCalc = ResultsCalculator.new 
      resultsCalc.perform(@game.id)

      $redis.exists(key).should == false
    end
  end

  describe "Error and Edge Cases: " do
    let(:user) { create(:user) }

    before(:each) do
      definition = Definition.where(unique_name: 'baseline').first
      @game  = Game.create_by_definition(definition, user)

      events_json = IO.read(File.expand_path('../../fixtures/test_event_log.json', __FILE__))
      @events = JSON.parse(events_json)
    end

    after(:each) do
      UserEvent.cleanup(@game.id)
    end

    it 'uses the events in the game.result.event_log if redis queue is empty' do
      # This is a scenario we may use to rerun some existing tests
      # This scenario should not happen normally in production
      @game.event_log = @events
      @game.save

      resultsCalc = ResultsCalculator.new 
      @game.status.should == :not_started
      resultsCalc.perform(@game.id)
      updated_game = Game.find(@game.id)
      updated_game.status.should == :results_ready.to_s
      user.personality.should_not be_nil    
      # user.personality.profile_description.name.should == 'The Charger'
      # user.personality.profile_description.name.should == 'The Shelter'      
    end

    it 'changes the game status to :no_results if there are no user_events anywhere' do
      resultsCalc = ResultsCalculator.new 
      @game.status.should == :not_started
      resultsCalc.perform(@game.id)
      updated_game = Game.find(@game.id)
      updated_game.status.should == :no_results.to_s
    end

    it 'leaves the user events in redis if game.save for the event_log fails' do
      Game.any_instance.stub(:save).and_return(false)
      key = "game:#{@game.id}"
      record_events_in_redis(@game, @events)
      $redis.exists(key).should == true
      resultsCalc = ResultsCalculator.new 
      resultsCalc.perform(@game.id)
      $redis.exists(key).should == true
    end

    it 'changes the game status to :no_results if one of the Persist calculators fail' do
      PersistPersonality.any_instance.stub(:persist) do |game, analysis_results|
        raise Exception.new
      end
      key = "game:#{@game.id}"
      record_events_in_redis(@game, @events)
      $redis.exists(key).should == true
      resultsCalc = ResultsCalculator.new 
      @game.status.should == :not_started
      lambda { resultsCalc.perform(@game.id) }.should raise_error(Exception)
      updated_game = Game.find(@game.id)
      updated_game.status.should == :no_results.to_s
      updated_game.event_log.should_not be_nil
      $redis.exists(key).should == false
    end
  end
end
