require 'csv'

class SpeedArchetypeDescriptionsSeed
  include SeedsHelper

  def create_seed
    path = File.expand_path('../data/speed_archetype_descriptions.csv', __FILE__)

    # Use the :encoding to make sure the strings are properly converted to UTF-8
    attributes = [:speed_archetype, :description]
    puts 'Creating SpeedArchetypeDescriptions'
    speed_whitelist = speed_archetype_whitelist

    CSV.foreach(path, :encoding => 'windows-1251:utf-8') do |row|
      profile_attr = {}
      # profile_attr[:bullet_description] = []
      row.each_with_index do |value, i|
        case i
          when 0..1
            profile_attr[attributes[i]] = value
          # when 2..4
          #   profile_attr[:bullet_description] << value
          else
            #Ignore
        end
      end
      if speed_whitelist[profile_attr[:speed_archetype]]
        profile_attr[:speed_archetype] = speed_whitelist[profile_attr[:speed_archetype]]
      else
        puts "Wrong dimension: #{profile_attr[:speed_archetype]}"
        raise Exception.new
      end

      profile_attr[:display_id] = profile_attr[:speed_archetype]
      profile = SpeedArchetypeDescription.where(speed_archetype: profile_attr[:speed_archetype]).first_or_initialize(profile_attr)
      profile.update_attributes(profile_attr)
      profile.speed_archetype = profile_attr[:speed_archetype]
      profile.save
      print '.'
    end
    puts
  end
end