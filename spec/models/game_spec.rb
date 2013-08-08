require 'spec_helper'

describe Game do 
  let(:user) { create(:user) }
  let(:guest) { create(:guest) }

  def create_definition(path)
    definition_json = IO.read(path)

    definition_attr = JSON.parse definition_json, :symbolize_names => true
    definition = Definition.where(unique_name: definition_attr[:unique_name]).first_or_initialize(definition_attr)
    definition.update_attributes(definition_attr)
    definition.save!
    definition
  end

  describe 'Creation' do 
    it 'creates a game from a game definition' do 
      definition = Definition.where(unique_name: 'baseline').first
      game  = Game.create_by_definition(definition, guest)

      game.should_not be_nil
      game.definition.should == definition
      game.name.should == definition.unique_name
      game.stages.should_not be_nil
      game.stages.length.should == 7
      game.user_id.should == guest.id
      game.event_log.should == {}
      game.status.should == :not_started
      game.stage_completed.should == -1
    end
  end

  describe 'Event log management' do 
    before :each do 
      events_json = IO.read(Rails.root.join('lib/analyze/spec/fixtures/aggregate_all.json'))
      @all_events = JSON.parse(events_json)

      definition = create_definition(Rails.root.join('lib/analyze/spec/fixtures/test_game_definition.json'))
      @game  = Game.create_by_definition(definition, guest)
    end

    it 'updates the event log for a single event log item' do 
      event =   {
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

      @game.update_event_log(event)
      @game.event_log.should_not be_empty
      
      @game.event_log.length.should == 1
      @game.event_log['2']['event_type'].should == 'image_rank'
      @game.event_log['2']['events'].should_not be_empty
    end

    it 'updates the event log for an array of event log items' do 
      @game.update_event_log(@all_events)
      @game.event_log.should_not be_empty
      @game.event_log.length.should == 7
      @game.event_log['2']['event_type'].should == 'image_rank'
      @game.event_log['2']['events'].should_not be_empty
    end

    it 'rewrites a stage in the event log, if the same stage events are given again' do 
      @game.update_event_log(@all_events)
      @game.event_log.should_not be_empty
      @game.event_log['2']['events'][0]['data'][0]['url'].should == "assets/devtest_images/F1a.jpg"

      event =   {
        "event_type" => "image_rank",
        "stage" => 2,
        "events" =>  [
          {"time" => 1360194798295,"event" => "level_started","data" => [{"url" => "foo.jpg","elements" => "color,human,male,man_made,movement,nature,pair,reflection,texture,whole","image_id" => "F1a","rank" => -1},{"url" => "assets/devtest_images/F1b.jpg","elements" => "color,male,man_made,pair,reflection","image_id" => "F1b","rank" => -1},{"url" => "assets/devtest_images/F1c.jpg","elements" => "color,human,human_eyes,male,man_made,movement,negative_space,pair,reflection,texture","image_id" => "F1c","rank" => -1},{"url" => "assets/devtest_images/F1d.jpg","elements" => "color,happy,human,human_eyes,nature,shading,texture,vista,whole","image_id" => "F1d","rank" => -1},{"url" => "assets/devtest_images/F1e.jpg","elements" => "color,human,male,man_made,movement,pair,reflection,shading,whole","image_id" => "F1e","rank" => -1}]},
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

      @game.update_event_log(event)
      @game.event_log['2']['events'][0]['data'][0]['url'].should == 'foo.jpg'
    end

    it 'raises an error if the events are not valid' do 
      event =   {
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
      event['events'].delete_at(0)

      expect { @game.update_event_log(event) }.to raise_error(Api::V1::UserEventValidatorError)
    end

    it 'returns true if all events are received' do 
      @game.update_event_log(@all_events)
      @game.event_log.length.should == 7
      @game.all_events_received?.should be_true
    end

    it 'returns false if all events are not received' do 
      @all_events.delete_at(1)
      @all_events.length.should == 6
      @game.update_event_log(@all_events)
      @game.all_events_received?.should be_false
    end


    it 'deletes stages from the event log' do 
      @game.update_event_log(@all_events)
      @game.event_log.length.should == 7
      
      event = { "stage" => 1 }

      @game.update_event_log(event)
      @game.event_log.length.should == 6
      @game.event_log.has_key?("1").should be_false
    end
  end
end
