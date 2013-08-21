require 'spec_helper'

describe ReactionTimeValidator do 
  before :each do 
    @events = { 
      "event_type" => "reaction_time",
      "stage" => 0,
      "events" => [
        {"time" => 1360194757876,"event" => "level_started", "sequence_type" => "simple", "data" => ["yellow:843","green:759","green:1367","green:986","green:741","red:506","yellow:910","green:951","red:1420","yellow:1383","yellow:638","yellow:1449","green:1090","yellow:1214","yellow:724","green:1375","red:575"]},
        {"time" => 1360194758722,"event" => "shown","color" => "yellow","index" => 0,"time_interval" => 843},
        {"time" => 1360194759485,"event" => "shown","color" => "green","index" => 1,"time_interval" => 759},
        {"time" => 1360194760257,"event" => "incorrect","color" => "green","index" => 1},
        {"time" => 1360194760855,"event" => "shown","color" => "green","index" => 2,"time_interval" => 1367},
        {"time" => 1360194761777,"event" => "incorrect","color" => "green","index" => 2},
        {"time" => 1360194761842,"event" => "shown","color" => "green","index" => 3,"time_interval" => 986},
        {"time" => 1360194762586,"event" => "shown","color" => "green","index" => 4,"time_interval" => 741},
        {"time" => 1360194763094,"event" => "shown","color" => "red","index" => 5,"time_interval" => 506},
        {"time" => 1360194763626,"event" => "correct","color" => "red","index" => 5},
        {"time" => 1360194764006,"event" => "shown","color" => "yellow","index" => 6,"time_interval" => 910},
        {"time" => 1360194764637,"event" => "incorrect","color" => "yellow","index" => 6},
        {"time" => 1360194764959,"event" => "shown","color" => "green","index" => 7,"time_interval" => 951},
        {"time" => 1360194766381,"event" => "shown","color" => "red","index" => 8,"time_interval" => 1420},
        {"time" => 1360194766524,"event" => "correct","color" => "red","index" => 8},
        {"time" => 1360194767068,"event" => "correct","color" => "red","index" => 8},
        {"time" => 1360194767766,"event" => "shown","color" => "yellow","index" => 9,"time_interval" => 1383},
        {"time" => 1360194768306,"event" => "incorrect","color" => "yellow","index" => 9},
        {"time" => 1360194768406,"event" => "shown","color" => "yellow","index" => 10,"time_interval" => 638},
        {"time" => 1360194769857,"event" => "shown","color" => "yellow","index" => 11,"time_interval" => 1449},
        {"time" => 1360194770922,"event" => "incorrect","color" => "yellow","index" => 11},
        {"time" => 1360194770948,"event" => "shown","color" => "green","index" => 12,"time_interval" => 1090},
        {"time" => 1360194771722,"event" => "incorrect","color" => "green","index" => 12},
        {"time" => 1360194772165,"event" => "shown","color" => "yellow","index" => 13,"time_interval" => 1214},
        {"time" => 1360194772891,"event" => "shown","color" => "yellow","index" => 14,"time_interval" => 724},
        {"time" => 1360194774267,"event" => "shown","color" => "green","index" => 15,"time_interval" => 1375},
        {"time" => 1360194774844,"event" => "shown","color" => "red","index" => 16,"time_interval" => 575},
        {"time" => 1360194775749,"event" => "correct","color" => "red","index" => 16},
        {"time" => 1360194775750,"event" => "level_completed","no" => 16},
        {"time" => 1360194958245,"event" => "level_summary"}
      ]
    }
  end

  it 'validates the reaction time events' do 
    validator = ReactionTimeValidator.new(@events)
    validation = validator.validate
    validation.should be_true
  end

  it 'raises an error if the data is missing on level_started' do 
    level_started = @events['events'][0]
    level_started['event'].should == 'level_started' 
    level_started['data'] = nil

    validator = ReactionTimeValidator.new(@events)
    expect { validator.validate }.to raise_error(Api::V1::UserEventValidatorError)     
  end

  it 'raises an error if the color is nil on shown' do 
    shown = @events['events'][1]
    shown['event'].should == 'shown' 
    shown['color'] = nil

    validator = ReactionTimeValidator.new(@events)
    expect { validator.validate }.to raise_error(Api::V1::UserEventValidatorError)     
  end

  it 'raises an error if the index is missing on shown' do 
    shown = @events['events'][1]
    shown['event'].should == 'shown' 
    shown.delete('index')

    validator = ReactionTimeValidator.new(@events)
    expect { validator.validate }.to raise_error(Api::V1::UserEventValidatorError)     
  end


  it 'raises an error if the data has incorrect format' do 
    level_started = @events['events'][0]
    level_started['event'].should == 'level_started' 
    level_started['data'] = ["foo"]

    validator = ReactionTimeValidator.new(@events)
    expect { validator.validate }.to raise_error(Api::V1::UserEventValidatorError)     
  end

  it 'raises an error if the data is not of type string' do 
    level_started = @events['events'][0]
    level_started['event'].should == 'level_started' 
    level_started['data'] = [{"yellow" => 123}]
    validator = ReactionTimeValidator.new(@events)
    expect { validator.validate }.to raise_error(Api::V1::UserEventValidatorError)     
  end

end