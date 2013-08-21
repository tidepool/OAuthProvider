require 'csv'

class ReactionTimeDescriptionsSeed
  include SeedsHelper

  def create_seed
    path = File.expand_path('../data/reaction_time_descriptions.csv', __FILE__)

    # Use the :encoding to make sure the strings are properly converted to UTF-8
    attributes = [:big5_dimension, :speed_archetype, :description, :b1, :b2, :b3]
    puts 'Creating ReactionTimeDescriptions'
    b5_whitelist = big5_whitelist
    speed_whitelist = speed_archetype_whitelist

    CSV.foreach(path, :encoding => 'windows-1251:utf-8') do |row|
      profile_attr = {}
      profile_attr[:bullet_description] = []
      row.each_with_index do |value, i|
        case i
          when 0..2
            profile_attr[attributes[i]] = value
          when 3..5
            profile_attr[:bullet_description] << value
          else
            #Ignore
        end
      end
      if b5_whitelist[profile_attr[:big5_dimension]]
        profile_attr[:big5_dimension] = b5_whitelist[profile_attr[:big5_dimension]]
      else
        puts "Wrong dimension: #{profile_attr[:big5_dimension]}"
        raise Exception.new
      end
      if speed_whitelist[profile_attr[:speed_archetype]]
        profile_attr[:speed_archetype] = speed_whitelist[profile_attr[:speed_archetype]]
      else
        puts "Wrong dimension: #{profile_attr[:speed_archetype]}"
        raise Exception.new
      end

      profile_attr[:display_id] = "#{profile_attr[:big5_dimension]}_#{profile_attr[:speed_archetype]}"
      profile = ReactionTimeDescription.where('big5_dimension = ? AND speed_archetype = ?', profile_attr[:big5_dimension], profile_attr[:speed_archetype]).first_or_initialize(profile_attr)
      profile.update_attributes(profile_attr)
      profile.big5_dimension = profile_attr[:big5_dimension]
      profile.speed_archetype = profile_attr[:speed_archetype]
      profile.save
      print '.'
    end
    puts
  end
end