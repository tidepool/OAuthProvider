require 'spec_helper'

describe InterestPickerValidator do 
  before :each do 
    @events = {
      "event_type": "interest_picker",
      "stage": 7,
      "events": [
        {"time":1360195167248, "event":"level_started"},
        {"time":1360195167848, "event":"selected", "value": "enterprising1", "type":"symbol" , "dimension": "enterprising" },
        {"time":1360195167848, "event":"deselected", "value": "enterprising1", "type":"symbol", "dimension": "enterprising" },    
        {"time":1360195167848, "event":"selected", "value": "mechanical", "type":"word", "dimension": "realistic" },
        {"time":1360195167248, "event":"level_completed" },
        {"time":1360195167548, "event":"level_summary",
          "symbol_list":[
            { "value": "enterprising1", "dimension": "enterprising" },
            { "value": "enterprising1", "dimension": "realistic" },
            { "value": "enterprising1", "dimension": "enterprising" }         
          ],
          "word_list": [
            { "value": "mechanical", "dimension": "realistic" },
            { "value": "mechanical", "dimension": "social" },
            { "value": "mechanical", "dimension": "realistic" },
            { "value": "mechanical", "dimension": "realistic" },
            { "value": "mechanical", "dimension": "social" },        
            { "value": "mechanical", "dimension": "investigative" },        
            { "value": "mechanical", "dimension": "conventional" }                
          ]
        }
      ]
    }
  end

  it 'validates the image_rank events' do 
    validator = InterestPickerValidator.new(@events)
    validation = validator.validate
    validation.should be_true
  end

  it 'raises an error if the data is missing keys' do 
    last_entry = @events['events'].length - 1
    level_summary = @events['events'][last_entry]
    level_summary['event'].should == 'level_summary' 
    item = level_summary.delete('symbol_list')

    validator = InterestPickerValidator.new(@events)
    expect { validator.validate }.to raise_error(Api::V1::UserEventValidatorError)     
  end

end