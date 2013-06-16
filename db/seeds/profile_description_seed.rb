require 'csv'

class ProfileDescriptionSeed
  include SeedsHelper

  def create_seed
    profile = ProfileDescription.first
    profile_path = File.expand_path('../data/profile_descriptions_new.csv', __FILE__)

    modified = check_if_inputs_modified(profile, profile_path)
    if modified
      # Use the :encoding to make sure the strings are properly converted to UTF-8
      attributes = [:big5_dimension, :holland6_dimension, :code, :name, :p1, :p2, :p3, :one_liner, :b1, :b2, :b3]
      puts 'Creating ProfileDescriptions'

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
        name = profile_attr[:name]
        filename = name.gsub(/ /, '-').gsub(/\'/, '')
        display_id = filename.downcase
        profile_attr[:logo_url] = "#{filename}.png"
        profile_attr[:display_id] = display_id
        profile = ProfileDescription.where(display_id: display_id).first_or_initialize(profile_attr)
        profile.save
        print '.'
      end
      puts
    end
  end
end