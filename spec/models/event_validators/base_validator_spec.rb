require 'spec_helper'

describe BaseValidator do 
  before :each do 
    @events = {
      "event_type" => "circles_test",
      "stage" =>  3,
      "events" => [
        {"time" => 1360194820934, "event" => "level_started" },
        {"time" => 1360194958241, "event" => "level_completed" },
        {"time" => 1360194958245, "event" => "level_summary"}
      ]
    }
  end

  it 'validates from an event log' do 
    validator = BaseValidator.new(@events)
    validation = validator.validate
    validation.should be_true
  end

  it 'raises an error if top level keys do not exist' do 
    @events.delete('event_type') 
    validator = BaseValidator.new(@events)
    expect { validator.validate }.to raise_error(Api::V1::UserEventValidatorError) 
  end

  it 'raises an error if expected event does not exist' do 
    deleted_event = @events['events'].delete_at(0)
    deleted_event['event'].should == 'level_started'

    validator = BaseValidator.new(@events)
    expect { validator.validate }.to raise_error(Api::V1::UserEventValidatorError)     
  end

  it 'raises an error if the same expected event is sent twice' do 
    @events['events'] << {"time" => 1360194958245, "event" => "level_summary"}

    validator = BaseValidator.new(@events)
    expect { validator.validate }.to raise_error(Api::V1::UserEventValidatorError)  
  end
end