require 'csv'

class FaceOffGenerator < BaseGenerator
  attr_accessor :picked_images, :max_tries

  def initialize(user)
    @image_list = initialize_images
    @nuanced_emotions = {
      "happy" => "Adoring,Affectionate,Love,Fonds,Caring,Amused,Blissful,Cheerful,Gleeful,Jovial,Delighted,Enjoyment,Ecstatic,Satisfied,Elated,Euphoric,Enthusiastic,Excited,Thrilled,Exhillirated,Contented,Pleased,Proud,Triumph,Eager,Hopeful,Optimistic,Enthralled,Relieved",
      "sad" => "Agony,Suffering,Hurted,Anguish,Depressed,Despaired,Hopelessness,Gloomy,Sad,Unhappy,Grieving,Sorrow,Woed,Misery,Dismayed,Disappointed,Displeased,Guilty,Ashamed,Regretful,Remorseful,Alienated,Isolated,Neglected,Defeated,Dejected,Insecure,Embarrassed,Humiliated,Insulted,Pity,Sympathy",
      "angry" => "Irritated,Aggravated,Agitated,Annoyed,Grouchy,Grumpy,Frustrated,Angry,Rage,Outraged,Furious,Hostile,Ferocious,Bitter,Hate,Dislike,Resentment,Envious,Jealous,Tormented",
      "afraid" => "",
      "disgusted" => "",
      "surprised" => ""
    }
  end

  def generate(stage_no, stage_template)
    stage = {}
    stage.merge!(stage_template)
    number_of_images = stage_template["number_of_images"].to_i || 5
    number_of_choices = stage_template["number_of_choices"].to_i || 4
    stage_type = stage_template["stage_type"] || 'primary_only'
    images = []
    picked_images = pick_random_from_array(@image_list[stage_type.to_sym], number_of_images)
    return stage if picked_images.nil?
    
    picked_images.each do |image|
      range = 0...@image_list[stage_type.to_sym].length
      # image = pick_random_from_array(@image_list[stage_type.to_sym], 1)
      emotions = []
      image_entry = {}
      image_entry["path"] = image[:name]
      image_entry["primary"] = image[:primary]
      image_entry["emo_group"] = image[:emo_group]
      
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
        emotions_list = @nuanced_emotions[image[:emo_group]].split(',')
        alternate_nuanced = pick_random_from_array(emotions_list, 3)
        nuanced_emotions.concat(alternate_nuanced)
        image_entry["nuanced_emotions"] = nuanced_emotions.shuffle
      end
      alternate = create_extra_choices(image, number_of_choices, emotions.length)
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

  def pick_random_from_array(list, number_of_picks)
    picked_list = []
    (0...number_of_picks).each do |i|
      index = Random.new.rand(list.length)
      picked_list << list[index]
      list = list - [list[index]]
    end
    number_of_picks > 1 ? picked_list : picked_list[0]
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
        attribute = attributes[i]
        desc_attr[attribute] = value.delete(' ') unless value.nil?
        desc_attr[attribute] = desc_attr[attribute].downcase if attribute == :emo_group
      end
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