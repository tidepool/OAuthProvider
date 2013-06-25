require 'csv'

class ProfileDescriptionSeed
  include SeedsHelper

  def create_seed
    create_profile_descriptions
    create_career_recommendations
  end

  def create_profile_descriptions
    profile_path = File.expand_path('../data/profile_descriptions_new.csv', __FILE__)

    # Use the :encoding to make sure the strings are properly converted to UTF-8
    attributes = [:big5_dimension, :holland6_dimension, :code, :name, :p1, :p2, :p3, :one_liner, :b1, :b2, :b3]
    puts 'Creating ProfileDescriptions'
    b5_whitelist = big5_whitelist
    h6_whitelist = holland6_whitelist

    CSV.foreach(profile_path, :encoding => 'windows-1251:utf-8') do |row|
      profile_attr = {}
      profile_attr[:description] = ""
      profile_attr[:bullet_description] = []
      row.each_with_index do |value, i|
        case i
          when 0..3
            profile_attr[attributes[i]] = value
          when 4..6
            # profile_attr[:description] << value
            profile_attr[:description] += value + "\n\n"
          when 7
            profile_attr[attributes[i]] = value
          when 8..10
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
      if h6_whitelist[profile_attr[:holland6_dimension]]
        profile_attr[:holland6_dimension] = h6_whitelist[profile_attr[:holland6_dimension]]
      else
        puts "Wrong dimension: #{profile_attr[:holland6_dimension]}"
        raise Exception.new
      end

      name = profile_attr[:name]
      filename = name.gsub(/ /, '-').gsub(/\'/, '')
      display_id = filename.downcase
      profile_attr[:logo_url] = "#{filename}.png"
      profile_attr[:display_id] = display_id
      profile = ProfileDescription.where('big5_dimension = ? AND holland6_dimension = ?', profile_attr[:big5_dimension], profile_attr[:holland6_dimension]).first_or_initialize(profile_attr)
      profile.update_attributes(profile_attr)
      profile.big5_dimension = profile_attr[:big5_dimension]
      profile.holland6_dimension = profile_attr[:holland6_dimension]
      profile.save
      print '.'
    end
    puts
  end

  def create_career_recommendations
    reco_path = File.expand_path('../data/careers_skills_tools.csv', __FILE__)

    # CSV Order of columns:
    # ID, Personality, Careers,   Skills,  Tools

    attributes = [:profile_description_id, :careers, :skills, :tools]
    puts 'Creating Career Recommendations'
    CSV.foreach(reco_path, :encoding => 'windows-1251:utf-8') do |row|
      reco_attr = {}
      personality_key = ""
      row.each_with_index do |value, i|
        if i == 0
          personality_key = value.gsub(/ /, '-').gsub(/\'/, '').downcase
        else
          reco_attr[attributes[i]] = value.split(':').map { |item| item.strip }
        end
      end
      profile_desc = ProfileDescription.where(display_id: personality_key).first 
      if profile_desc
        reco = CareerRecommendation.where(profile_description_id: profile_desc.id).first_or_initialize()
        reco.update_attributes(reco_attr)
        reco.profile_description_id = profile_desc.id
        reco.save
        print '.'
      else
        puts "Profile Description #{personality_key} not found!"
        raise Exception.new
      end
    end
    puts
  end
end