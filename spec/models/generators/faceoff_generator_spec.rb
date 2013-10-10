require 'spec_helper'

describe FaceOffGenerator do
  before :each do 
    definition_json = IO.read(Rails.root.join('db/seeds/data/definitions/faceoff.json'))
    @definition = JSON.parse(definition_json)
  end

  it 'initializes an in-memory representation of emo images' do
    generator = FaceOffGenerator.new(nil)

    images = generator.initialize_images
    images.should_not be_empty
    images.length.should == 3
  end

  it 'picks a random image from a set of images' do 
    generator = FaceOffGenerator.new(nil)
    generator.picked_images = { "foo1" => true, "foo2" => true, "bar2" => true }
    generator.max_tries = 100

    images = [{name: "foo1"}, {name: "foo2"}, {name: "bar1"}, {name: "bar2"}]
    image = generator.pick_random((0...images.length), images)
    image.should_not be_nil
    image[:name].should == "bar1"
  end

  it 'generates the correct stages' do 
    generator = FaceOffGenerator.new(nil)
    stage = generator.generate(0, @definition["stages"][0])
    stage.should_not be_nil
    stage["images"].length.should == stage["number_of_images"].to_i
  end

  it 'caps the choices to the number_of_choices' do 
    generator = FaceOffGenerator.new(nil)
    image = { alternate: "anger,shame,happiness"}
    choices = generator.create_extra_choices(image, 4, 2)
    choices.length.should == 2
    choices[0].should == 'anger'
    choices[1].should == 'shame'

    choices = generator.create_extra_choices(image, 3, 2)
    choices.length.should == 1

    choices = generator.create_extra_choices(image, 3, 3)
    choices.length.should == 0

    choices = generator.create_extra_choices(image, 5, 1)
    choices.length.should == 3
  end

  it 'picks 3 random emotions from a list' do 
    generator = FaceOffGenerator.new(nil)
    emotions = "Adoring,Affectionate,Love,Fonds,Caring,Amused,Blissful,Cheerful,Gleeful,Jovial,Delighted,Enjoyment,Ecstatic,Satisfied,Elated,Euphoric,Enthusiastic,Excited,Thrilled,Exhillirated,Contented,Pleased,Proud,Triumph,Eager,Hopeful,Optimistic,Enthralled,Relieved"
    random_emotions = generator.pick_random_emotion(emotions)
    random_emotions.length.should == 3    
  end

  it 'generates a primary_only stage' do 
    stage = {
        "friendly_name" => "Face Off",
        "instructions" => "Find the emotion behind the face.",
        "view_name" => "FaceOff",
        "client_view_name" => "FaceOff",
        "image_url_base" => "",
        "stage_type" => "primary_only",
        "time_to_show" => 1000,
        "primary_multiplier" => 2,
        "secondary_multiplier" => 1,
        "difficulty_multiplier" => 1,
        "number_of_images" => 3, 
        "number_of_choices" => 4
      }
    generator = FaceOffGenerator.new(nil)
    output = generator.generate(0, stage)

    output.should_not be_nil

  end

  it 'generates a primary_secondary stage' do 
    stage = {
        "friendly_name" => "Face Off",
        "instructions" => "Find the emotion behind the face.",
        "view_name" => "FaceOff",
        "client_view_name" => "FaceOff",
        "image_url_base" => "",
        "stage_type" => "primary_secondary",
        "time_to_show" => 1000,
        "primary_multiplier" => 2,
        "secondary_multiplier" => 1,
        "difficulty_multiplier" => 1,
        "number_of_images" => 3, 
        "number_of_choices" => 4
      }
    generator = FaceOffGenerator.new(nil)
    output = generator.generate(0, stage)
    output.should_not be_nil

  end

  it 'generates a primary_nuanced stage' do 
    stage = {
        "friendly_name" => "Face Off",
        "instructions" => "Find the emotion behind the face.",
        "view_name" => "FaceOff",
        "client_view_name" => "FaceOff",
        "image_url_base" => "",
        "stage_type" => "primary_nuanced",
        "time_to_show" => 1000,
        "primary_multiplier" => 2,
        "secondary_multiplier" => 1,
        "difficulty_multiplier" => 1,
        "number_of_images" => 3, 
        "number_of_choices" => 4
      }
    generator = FaceOffGenerator.new(nil)
    output = generator.generate(0, stage)
    output.should_not be_nil

  end

end