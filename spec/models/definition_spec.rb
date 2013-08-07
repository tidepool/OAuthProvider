require 'spec_helper'

describe Definition do

  it 'creates a definition for the baseline game' do 
    definition = Definition.default
    stages = definition.stages_from_stage_definition
    stages.should_not be_nil
    stages.length.should == 7
    stages[0]["image_sequence"].length.should == 5
    stages[0]["image_sequence"].should == [
      {
        :image_id => "F2a",
        :elements => "anger,color,human,human_eyes,movement,negative_space,pair,reflection,whole",
             :url => "/images/devtest_images/F2a.jpg"
      },
      {
        :image_id => "F2b",
        :elements => "color,male,man_made,pair,reflection,shading,texture",
             :url => "/images/devtest_images/F2b.jpg"
      },
      {
        :image_id => "F2c",
        :elements => "color,human,human_eyes,male,man_made,sadness,shading,texture,whole",
             :url => "/images/devtest_images/F2c.jpg"
      },
      {
        :image_id => "F2d",
        :elements => "achromatic,human,human_eyes,negative_space,pair,reflection,sadness,shading,texture",
             :url => "/images/devtest_images/F2d.jpg"
      },
      {
        :image_id => "F2e",
        :elements => "color,male,man_made,negative_space,pair,reflection,texture,whole",
             :url => "/images/devtest_images/F2e.jpg"
      }
    ]    
  end
end