require 'csv'

class FaceOffGenerator < BaseGenerator
  attr_accessor :picked_images, :max_tries

  MAX_TRIES = 3
  def initialize(user)
    @image_list = initialize_images
    @picked_images = {}
    @max_tries = MAX_TRIES
    @nuanced_emotions = {
      "Happy" => "Adoring,Affectionate,Love,Fonds,Caring,Amused,Blissful,Cheerful,Gleeful,Jovial,Delighted,Enjoyment,Ecstatic,Satisfied,Elated,Euphoric,Enthusiastic,Excited,Thrilled,Exhillirated,Contented,Pleased,Proud,Triumph,Eager,Hopeful,Optimistic,Enthralled,Relieved",
      "Sad" => "Agony,Suffering,Hurted,Anguish,Depressed,Despaired,Hopelessness,Gloomy,Sad,Unhappy,Grieving,Sorrow,Woed,Misery,Dismayed,Disappointed,Displeased,Guilty,Ashamed,Regretful,Remorseful,Alienated,Isolated,Neglected,Defeated,Dejected,Insecure,Embarrassed,Humiliated,Insulted,Pity,Sympathy",
      "Angry" => "Irritated,Aggravated,Agitated,Annoyed,Grouchy,Grumpy,Frustrated,Angry,Rage,Outraged,Furious,Hostile,Ferocious,Bitter,Hate,Dislike,Resentment,Envious,Jealous,Tormented"
    }
  end

  def generate(stage_no, stage_template)
    stage = {}
    # difficulty_map = {
    #   "1" => 1,
    #   "2" => 2, 
    #   "3" => 3
    # }
    stage.merge!(stage_template)
    # difficulty_multiplier = stage_template["difficulty_multiplier"].to_s
    # difficulty = difficulty_map[difficulty_multiplier].to_i || 0
    number_of_images = stage_template["number_of_images"].to_i || 5
    number_of_choices = stage_template["number_of_choices"].to_i || 4
    stage_type = stage_template["stage_type"] || 'primary_only'
    images = []
    (0...number_of_images).each do |i|
      range = 0...@image_list[stage_type.to_sym].length
      image = pick_random(range, @image_list[stage_type.to_sym])

      emotions = []
      image_entry = {}
      image_entry["path"] = image[:name]
      image_entry["primary"] = image[:primary]
      
      emotions << image[:primary]

      case stage_type.to_sym
      when :primary_only

      when :primary_secondary
        image_entry["secondary"] = image[:secondary]
        emotions << image[:secondary]
      when :primary_nuanced
        image_entry["primary_nuanced"] = image[:nuanced]
        nuanced_emotions = []
        nuanced_emotions << image[:nuanced]
        alternate_nuanced = pick_random_emotion(@nuanced_emotions[image[:emo_group]])
        nuanced_emotions.concat(alternate_nuanced)
        image_entry["nuanced_emotions"] = nuanced_emotions.shuffle
      end
      alternate = create_extra_choices(image, number_of_choices, emotions.length)
           
      # unless image[:secondary].nil?
      #   image_entry["secondary"] = image[:secondary] 
      #   emotions << image[:secondary]
      # end
      
      # alternate = image[:alternate].split(',') 
      emotions.concat(alternate) 
      image_entry["emotions"] = emotions.shuffle
      images << image_entry
    end
    stage["images"] = images
    stage
  end

  def create_extra_choices(image, number_of_choices, existing)
    return [] if existing >= number_of_choices
    choices = image[:alternate].split(',') 
    number_of_choices_left = number_of_choices - existing 
    choices_left = []
    choices.each_with_index do | emotion, i |
      break if i >= number_of_choices_left
      choices_left << emotion 
    end
    choices_left
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

  def pick_random_emotion(emotions)
    emotion_list = emotions.split(',')
    range = emotion_list.length
    picked_emotions = {}
    listed_emotions = []
    (0...3).each do |i|
      (0...@max_tries).each do |i|
        random_generator = Random.new
        index = random_generator.rand(range)
        emotion = emotion_list[index]
        if @picked_images[emotion].nil? || i == (@max_tries - 1)
          @picked_images[emotion] = true
          listed_emotions << emotion
          break
        end
      end
    end
    listed_emotions
  end

  def initialize_images
    images = {
      primary_only: [],
      primary_secondary: [],
      primary_nuanced: []
    }
    emo_image_path = Rails.root.join('db/seeds/data/emo_images.csv')
    attributes = [:name, :emo_group, :primary, :secondary, :nuanced, :alternate]
    CSV.foreach(emo_image_path, :encoding => 'windows-1251:utf-8') do |row|
      desc_attr = {}
      row.each_with_index do |value, i|
        desc_attr[attributes[i]] = value.delete(' ') unless value.nil?
      end
      # difficulty = desc_attr[:difficulty].to_i || 0
      bucket = :primary_only
      if desc_attr[:secondary] && !desc_attr[:secondary].empty?
        bucket = :primary_secondary
      elsif desc_attr[:nuanced] && !desc_attr[:nuanced].empty?
        bucket = :primary_nuanced
      end
        
      images[bucket] <<  desc_attr
    end
    images
  end
end