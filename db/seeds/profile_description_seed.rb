require 'csv'

class ProfileDescriptionSeed
  include SeedsHelper

  def create_seed
    profile = ProfileDescription.first
    profile_path = File.expand_path('../data/profile_descriptions_utf8.csv', __FILE__)

    modified = check_if_inputs_modified(profile, profile_path)
    if modified
      # Use the :encoding to make sure the strings are properly converted to UTF-8
      attributes = [:big5_dimension, :holland6_dimension, :code, :name, :p1, :p2, :p3, :one_liner, :b1, :b2, :b3]
      CSV.foreach(profile_path, :encoding => 'windows-1251:utf-8') do |row|
        profile_attr = {}
        profile_attr[:description] = '['
        profile_attr[:bullet_description] = '['
        row.each_with_index do |value, i|
          case i
            when 0..3
              profile_attr[attributes[i]] = value
            when 4..6
              profile_attr[:description] += "{ p: '#{value}' },"
            when 7
              profile_attr[attributes[i]] = value
            when 8..10
              profile_attr[:bullet_description] += "{ p: '#{value}' },"
            else
              #Ignore
          end
        end
        profile_attr[:description].chop!
        profile_attr[:description] += ']'
        profile_attr[:bullet_description].chop!
        profile_attr[:bullet_description] += ']'
        profile_attr[:logo_url] = "#{profile_attr[:name]}.png"
        profile = ProfileDescription.where(name: profile_attr[:name]).first_or_initialize(profile_attr)
        profile.update_attributes(profile_attr)
        puts "Profile Description created = #{profile.to_s}"

        profile.save
      end
    end
  end
end