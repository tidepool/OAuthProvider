require 'csv'

class ImageElementsSeed
  include SeedsHelper

  def create_seed
    puts "Seeding images with elements"
    image = Image.first
    image_elements_path = File.expand_path('../data/image_elements.csv', __FILE__)
    image_coding_path = File.expand_path('../data/image_codings.csv', __FILE__)

    modified = check_if_inputs_modified(image, image_elements_path, image_coding_path)
    if image.nil? or modified
      puts "Elements changes, seeding now..."
      image_elements = []
      CSV.foreach(image_elements_path) do |row|
        image_elements = row
      end 
      CSV.foreach(image_coding_path) do |element_values|
        image_name = ""
        element_list = ""
        primary_color = ""
        count = 0
        element_values.each do |value|
          if count == 0
            # First is the name of image
            image_name = value if count == 0 
          else
            element_name = image_elements[count - 1]
            # "cf:" is a legacy prefix, if it exists remove it.
            element_name = element_name[3..-1] if element_name[0..2] == "cf:"
            element_list += "#{element_name}," if value == "1"     
            primary_color = value if image_elements[count - 1] == "cf:primary_color"
          end
          count += 1
        end
        image = Image.where(name: image_name).first_or_initialize({
            elements: element_list,
            primary_color: primary_color
          })
        if !image.nil?
          image.elements = element_list.chomp(',')
          image.primary_color = primary_color
          puts "Image created - #{image.name}, #{image.elements}, Color:#{image.primary_color}"
          image.save
        end
      end
    end
  end
end
