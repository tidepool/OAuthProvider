require 'spec_helper'

describe SurveyValidator do 
  before :each do 
    @events = {
      "event_type" => "survey",
      "stage" => 4,
      "events" => [
        {"time" => 1360195167248, "event" => "level_started" },
        {"time" => 1360195167848, "event" => "changed", "question_id" => "demand_1234", "topic" => "demand", "answer" => 5},
        {"time" => 1360195167248, "event" => "level_completed" },
        {"time" => 1360195167548, "event" => "level_summary",
          "data" => [
            {"question_id" => "demand_1234", "topic" => "demand", "answer" => 5}, 
            {"question_id" => "productivity_1234", "topic" => "productivity", "answer" => 3},
            {"question_id" => "stress_1111", "topic" => "stress", "answer" => 2}
          ]
        }
      ]
    }
  end

  it 'validates the image_rank events' do 
    validator = SurveyValidator.new(@events)
    validation = validator.validate
    validation.should be_true
  end

  it 'raises an error if the data is missing keys' do 
    last_entry = @events['events'].length - 1
    level_completed = @events['events'][last_entry]
    level_completed['event'].should == 'level_summary' 
    item = level_completed['data'][0].delete('question_id')

    validator = SurveyValidator.new(@events)
    expect { validator.validate }.to raise_error(Api::V1::UserEventValidatorError)     
  end

end