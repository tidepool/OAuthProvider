require 'spec_helper'

describe ResultsCalculator do

  describe 'Personality game calculation' do
    let(:guest) { create(:guest) }

    before(:each) do
      definition = Definition.where(unique_name: 'baseline').first
      @game  = Game.create_by_definition(definition, guest)

      events_json = IO.read(Rails.root.join('lib/analyze/spec/fixtures/aggregate_all.json'))
      events = JSON.parse(events_json)
      @game.update_event_log(events)
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

      # Below result depends on the exact dataset we fed from aggregate_all.json
      guest.personality.should_not be_nil    
      guest.personality.profile_description.name.should_not be_nil
      guest.personality.big5_dimension.should_not be_nil
      guest.personality.holland6_dimension.should_not be_nil
      guest.personality.big5_low.should_not be_nil
      guest.personality.big5_high.should_not be_nil
      guest.personality.holland6_score.should_not be_nil
      guest.personality.big5_score.should_not be_nil
      guest.personality.profile_description.name.should == 'The Sparkler'
      guest.personality.big5_dimension.should == 'high_extraversion'
      guest.personality.holland6_dimension.should == 'social'
      guest.personality.big5_low.should == 'openness'
      guest.personality.big5_high.should == 'extraversion'
    end

  end

  describe 'Reaction-Time game calculation' do
    let(:user) { create(:user) }

    before(:each) do
      definition = Definition.where(unique_name: 'reaction_time').first
      @game  = Game.create_by_definition(definition, user)

      events_json = IO.read(Rails.root.join('lib/analyze/spec/fixtures/aggregate_all.json'))
      events = JSON.parse(events_json)
      @game.update_event_log(events)
    end

    it 'calculates the reaction-time and survey results' do
      resultsCalc = ResultsCalculator.new 
      @game.status.should == :not_started
      resultsCalc.perform(@game.id)

      updated_game = Game.find(@game.id)
      updated_game.status.should == :results_ready.to_s
      updated_game.results.length.should == 2

      updated_game.results[0].type.should == "SurveyResult"
      updated_game.results[1].type.should == "ReactionTimeResult"
    end
  end

  describe 'Snoozer game calculation' do
    let(:user) { create(:user) }

    before(:each) do
      definition = Definition.where(unique_name: 'snoozer').first
      @game  = Game.create_by_definition(definition, user)

      events_json = IO.read(Rails.root.join('lib/analyze/spec/fixtures/aggregate_snoozer2.json'))
      events = JSON.parse(events_json)
      @game.update_event_log(events)
    end

    it 'calculates the reaction-time and survey results' do
      resultsCalc = ResultsCalculator.new 
      @game.status.should == :not_started
      resultsCalc.perform(@game.id)
      
      updated_game = Game.find(@game.id)
      updated_game.status.should == :results_ready.to_s
      updated_game.results.length.should == 2

      updated_game.results[0].type.should == "SurveyResult"
      updated_game.results[1].type.should == "SpeedArchetypeResult"
    end
  end


  describe 'Error and Edge Cases: ' do
    let(:user) { create(:user) }

    before(:each) do
      definition = Definition.where(unique_name: 'baseline').first
      @game  = Game.create_by_definition(definition, user)

      events_json = IO.read(Rails.root.join('lib/analyze/spec/fixtures/aggregate_all.json'))
      @events = JSON.parse(events_json)
    end

    it 'does nothing if there are no user_events anywhere' do
      resultsCalc = ResultsCalculator.new 
      @game.status.should == :not_started
      resultsCalc.perform(@game.id)
      updated_game = Game.find(@game.id)
      updated_game.status.should == @game.status.to_s
    end

    it 'changes the game status to :incomplete_results if one of the Persist calculators fail' do
      TidepoolAnalyze::AnalyzeDispatcher.any_instance.stub(:analyze) do | events, recipe_names|
        raise Exception.new
      end

      @game.update_event_log(@events)
      resultsCalc = ResultsCalculator.new 
      @game.status.should == :not_started
      resultsCalc.perform(@game.id) 
      updated_game = Game.find(@game.id)
      updated_game.status.should == :incomplete_results.to_s
    end

    it 'changes the game status to :incomplete_results if one of the Persist calculators fail' do
      PersistPersonality.any_instance.stub(:persist) do |game, analysis_results|
        raise Exception.new
      end
      @game.update_event_log(@events)
      resultsCalc = ResultsCalculator.new 
      @game.status.should == :not_started
      resultsCalc.perform(@game.id) 
      updated_game = Game.find(@game.id)
      updated_game.status.should == :incomplete_results.to_s
    end
  end
end
