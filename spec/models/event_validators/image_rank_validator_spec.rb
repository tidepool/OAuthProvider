require 'spec_helper'

describe ImageRankValidator do 
  before :each do 
    @events = {
      "event_type" => "image_rank",
      "stage" => 0,
      "events" => [
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
  end

  it 'validates the image_rank events' do 
    validator = ImageRankValidator.new(@events)
    validation = validator.validate
    validation.should be_true
  end

  it 'raises an error if the data is not in correct format of array' do 
    level_started = @events['events'][0]
    level_started['event'].should == 'level_started' 
    level_started['data'] = {"foo" => "bar"}

    validator = ImageRankValidator.new(@events)
    expect { validator.validate }.to raise_error(Api::V1::UserEventValidatorError)     
  end

  it 'raises an error if the data is missing keys' do 
    level_started = @events['events'][0]
    level_started['event'].should == 'level_started' 
    item = level_started['data'][0].delete('elements')

    validator = ImageRankValidator.new(@events)
    expect { validator.validate }.to raise_error(Api::V1::UserEventValidatorError)     
  end

  it 'raises an error if the level summary is missing final_rank' do 
    last_entry = @events['events'].length - 1
    level_summary = @events['events'][last_entry]
    level_summary['event'].should == 'level_summary' 
    level_summary.delete('final_rank')

    validator = ImageRankValidator.new(@events)
    expect { validator.validate }.to raise_error(Api::V1::UserEventValidatorError)     
  end

  it 'raises an error if the level summary is has non numeric items in final_rank' do 
    last_entry = @events['events'].length - 1
    level_summary = @events['events'][last_entry]
    level_summary['event'].should == 'level_summary' 
    level_summary['final_rank'] = ['1', 'v']
    validator = ImageRankValidator.new(@events)
    expect { validator.validate }.to raise_error(Api::V1::UserEventValidatorError)     
  end

  it 'raises an error if the level summary is has negative items in final_rank' do 
    last_entry = @events['events'].length - 1
    level_summary = @events['events'][last_entry]
    level_summary['event'].should == 'level_summary' 
    level_summary['final_rank'] = [-1, 2]

    validator = ImageRankValidator.new(@events)
    expect { validator.validate }.to raise_error(Api::V1::UserEventValidatorError)     
  end

end