require 'csv'

class FaceOffGenerator < BaseGenerator
  attr_accessor :picked_images, :max_tries

  MAX_TRIES = 3
  def initialize(user)
    @image_list = initialize_images
    @picked_images = {}
    @max_tries = MAX_TRIES
  end

  def generate(stage_no, stage_template)
    stage = {}
    difficulty_map = {
      "1" => 0,
      "2" => 1, 
      "2.2" => 2, 
      "2.5" => 3,
      "3" => 4
    }
    stage.merge!(stage_template)
    difficulty_multiplier = stage_template["difficulty_multiplier"].to_s
    difficulty = difficulty_map[difficulty_multiplier].to_i || 0
    number_of_images = stage_template["number_of_images"].to_i || 5
    images = []
    (0...number_of_images).each do |i|
      range = 0...@image_list[difficulty].length
      image = pick_random(range, @image_list[difficulty])

      emotions = []
      image_entry = {}
      image_entry["path"] = image[:name]
      image_entry["primary"] = image[:primary]
      unless image[:secondary].nil?
        image_entry["secondary"] = image[:secondary] 
        emotions << image[:secondary]
      end
      emotions << image[:primary]
      alternate = image[:alternate].split(',') 
      emotions.concat(alternate) 
      image_entry["emotions"] = emotions.shuffle
      images << image_entry
    end
    stage["images"] = images
    stage
  end

  def pick_random(range, images)
    selected_image = {}
    (0...@max_tries).each do |i|
      random_generator = Random.new
      index = random_generator.rand(range)
      name = images[index][:name]
      if @picked_images[name].nil? || i == (@max_tries - 1)
        @picked_images[name] = true
        selected_image = images[index]
        break
      end
    end
    selected_image
  end

  def initialize_images
    images = []
    (0..4).each do |i|
      images << []
    end
    emo_image_path = Rails.root.join('db/seeds/data/emo_images.csv')
    attributes = [:name, :primary, :secondary, :difficulty, :alternate]
    CSV.foreach(emo_image_path, :encoding => 'windows-1251:utf-8') do |row|
      desc_attr = {}
      row.each_with_index do |value, i|
        desc_attr[attributes[i]] = value.delete(' ') unless value.nil?
      end
      difficulty = desc_attr[:difficulty].to_i || 0
      images[difficulty] <<  desc_attr
    end
    images
  end
end