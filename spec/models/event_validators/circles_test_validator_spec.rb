require 'spec_helper'

describe CirclesTestValidator do 
  before :each do 
    @events = { 
      "event_type" => "circles_test",
      "stage" =>  3,
      "events" => [
        {"time" => 1360194820934, "event" => "level_started" },
        {"time" => 1360194823936, "event" => "resized", "item_no" => "1", "new_size" => 1 },
        {"time" => 1360194825276, "event" => "resized", "item_no" => "0", "new_size" => 2 },
        {"time" => 1360194827133, "event" => "resized", "item_no" => "2", "new_size" => 0 },
        {"time" => 1360194830361, "event" => "resized", "item_no" => "3", "new_size" => 4 },
        {"time" => 1360194831713, "event" => "resized", "item_no" => "4", "new_size" => 2 },
        {"time" => 1360194835894, "event" => "sublevel_initialize", "data" => [{"trait1" => "Self-Disciplined","trait2" => "Persistent","size" => 2,"changed" => true,"moved" => false,"top" => 130,"left" => 86,"width" => 132,"height" => 132,"textMarginTop" => 33,"sliderMarginLeft" => 38},{"trait1" => "Anxious","trait2" => "Dramatic","size" => 1,"changed" => true,"moved" => false,"top" => 136,"left" => 322,"width" => 120,"height" => 120,"textMarginTop" => 27,"sliderMarginLeft" => 32},{"trait1" => "Curious","trait2" => "Cultured","size" => 0,"changed" => true,"moved" => false,"top" => 277,"left" => 213,"width" => 108,"height" => 108,"textMarginTop" => 21,"sliderMarginLeft" => 26},{"trait1" => "Sociable","trait2" => "Adventurous","size" => 4,"changed" => true,"moved" => false,"top" => 388,"left" => 74,"width" => 156,"height" => 156,"textMarginTop" => 45,"sliderMarginLeft" => 50},{"trait1" => "Cooperative","trait2" => "Friendly","size" => 2,"changed" => true,"moved" => false,"top" => 400,"left" => 316,"width" => 132,"height" => 132,"textMarginTop" => 33,"sliderMarginLeft" => 38}]},
        {"time" => 1360194838399, "event" => "start_move", "item_no" => "1","item" => {"trait1" => "Anxious","trait2" => "Dramatic","size" => 1,"changed" => true,"moved" => false,"top" => 136,"left" => 322,"width" => 120,"height" => 120,"textMarginTop" => 27,"sliderMarginLeft" => 32}},
        {"time" => 1360194839132, "event" => "end_move","item_no" => "1","item" => {"trait1" => "Anxious","trait2" => "Dramatic","size" => 1,"changed" => true,"moved" => true,"top" => 161,"left" => 656,"width" => 120,"height" => 120,"textMarginTop" => 27,"sliderMarginLeft" => 32}},
        {"time" => 1360194840564, "event" => "start_move","item_no" => "2","item" => {"trait1" => "Curious","trait2" => "Cultured","size" => 0,"changed" => true,"moved" => false,"top" => 277,"left" => 213,"width" => 108,"height" => 108,"textMarginTop" => 21,"sliderMarginLeft" => 26}},
        {"time" => 1360194843140, "event" => "end_move","item_no" => "2","item" => {"trait1" => "Curious","trait2" => "Cultured","size" => 0,"changed" => true,"moved" => true,"top" => 275,"left" => 789,"width" => 108,"height" => 108,"textMarginTop" => 21,"sliderMarginLeft" => 26}},
        {"time" => 1360194848411, "event" => "start_move","item_no" => "4","item" => {"trait1" => "Cooperative","trait2" => "Friendly","size" => 2,"changed" => true,"moved" => false,"top" => 400,"left" => 316,"width" => 132,"height" => 132,"textMarginTop" => 33,"sliderMarginLeft" => 38}},
        {"time" => 1360194849868, "event" => "end_move","item_no" => "4","item" => {"trait1" => "Cooperative","trait2" => "Friendly","size" => 2,"changed" => true,"moved" => true,"top" => 126,"left" => 887,"width" => 132,"height" => 132,"textMarginTop" => 33,"sliderMarginLeft" => 38}},
        {"time" => 1360194852026, "event" => "start_move","item_no" => "3","item" => {"trait1" => "Sociable","trait2" => "Adventurous","size" => 4,"changed" => true,"moved" => false,"top" => 388,"left" => 74,"width" => 156,"height" => 156,"textMarginTop" => 45,"sliderMarginLeft" => 50}},
        {"time" => 1360194854206, "event" => "end_move","item_no" => "3","item" => {"trait1" => "Sociable","trait2" => "Adventurous","size" => 4,"changed" => true,"moved" => true,"top" => 351,"left" => 538,"width" => 156,"height" => 156,"textMarginTop" => 45,"sliderMarginLeft" => 50}},
        {"time" => 1360194855944, "event" => "start_move","item_no" => "0","item" => {"trait1" => "Self-Disciplined","trait2" => "Persistent","size" => 2,"changed" => true,"moved" => false,"top" => 130,"left" => 86,"width" => 132,"height" => 132,"textMarginTop" => 33,"sliderMarginLeft" => 38}},
        {"time" => 1360194857575, "event" => "end_move","item_no" => "0","item" => {"trait1" => "Self-Disciplined","trait2" => "Persistent","size" => 2,"changed" => true,"moved" => true,"top" => 149,"left" => 375,"width" => 132,"height" => 132,"textMarginTop" => 33,"sliderMarginLeft" => 38}},
        {"time" => 1360194958241, "event" => "level_completed" },
        {"time" => 1360194958245, "event" => "level_summary","data" => [{"trait1" => "Self-Disciplined","trait2" => "Persistent","size" => 2,"changed" => true,"moved" => true,"top" => 149,"left" => 375,"width" => 132,"height" => 132,"textMarginTop" => 33,"sliderMarginLeft" => 38},{"trait1" => "Anxious","trait2" => "Dramatic","size" => 1,"changed" => true,"moved" => true,"top" => 161,"left" => 656,"width" => 120,"height" => 120,"textMarginTop" => 27,"sliderMarginLeft" => 32},{"trait1" => "Curious","trait2" => "Cultured","size" => 0,"changed" => true,"moved" => true,"top" => 275,"left" => 789,"width" => 108,"height" => 108,"textMarginTop" => 21,"sliderMarginLeft" => 26},{"trait1" => "Sociable","trait2" => "Adventurous","size" => 4,"changed" => true,"moved" => true,"top" => 351,"left" => 538,"width" => 156,"height" => 156,"textMarginTop" => 45,"sliderMarginLeft" => 50},{"trait1" => "Cooperative","trait2" => "Friendly","size" => 2,"changed" => true,"moved" => true,"top" => 126,"left" => 887,"width" => 132,"height" => 132,"textMarginTop" => 33,"sliderMarginLeft" => 38}],"self_coord" => {"top" => 138,"left" => 634,"size" => 386}}
      ]
    }
  end

  it 'raises an error if the custom validator fails' do 
    last_entry = @events['events'].length - 1
    level_summary = @events['events'][last_entry]
    level_summary['event'].should == 'level_summary' 
    level_summary['data'] = nil

    validator = CirclesTestValidator.new(@events)
    expect { validator.validate }.to raise_error(Api::V1::UserEventValidatorError)     
  end

  it 'raises an error if size of circle is missing' do 
    last_entry = @events['events'].length - 1
    level_summary = @events['events'][last_entry]
    level_summary['event'].should == 'level_summary' 
    data = level_summary['data']
    data[1].delete('trait1')

    validator = CirclesTestValidator.new(@events)
    expect { validator.validate }.to raise_error(Api::V1::UserEventValidatorError)             
  end
end