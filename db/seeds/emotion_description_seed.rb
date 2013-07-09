require 'csv'

class EmotionDescriptionSeed
  include SeedsHelper

  def create_seed
    desc = EmotionDescription.first
    desc_path = File.expand_path('../data/emotion_descriptions.csv', __FILE__)

    modified = check_if_inputs_modified(desc, desc_path)
    if modified
      # CSV Order of columns:
      # Personality,Type of Recommendation,Sentence Summary,Title,Link
      whitelist = emo_whitelist

      attributes = [:name, :title, :description]
      puts 'Creating Emotion Descriptions'
      CSV.foreach(desc_path, :encoding => 'windows-1251:utf-8') do |row|
        desc_attr = {}
        row.each_with_index do |value, i|
          desc_attr[attributes[i]] = value
        end
        if whitelist[desc_attr[:name]]
          desc_attr[:name] = whitelist[desc_attr[:name]]
        else
          puts "Wrong dimension: #{desc_attr[:name]}"
          raise Exception.new
        end
        desc_attr[:icon_url] = "#{desc_attr[:name]}.png"

        desc = EmotionDescription.where(name: desc_attr[:name]).first_or_initialize(desc_attr)
        desc.update_attributes(desc_attr)
        desc.name = desc_attr[:name] # Ensure the old values with spaces are wiped
        desc.save
        print '.'
      end
    end
    puts

  end
end