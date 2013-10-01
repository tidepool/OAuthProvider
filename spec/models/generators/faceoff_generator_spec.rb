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
    images.length.should == 5
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
end