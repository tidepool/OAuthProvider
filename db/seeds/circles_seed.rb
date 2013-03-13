require 'csv'

class CirclesSeed
  include SeedsHelper

  def create_seed
    puts "Seeding elements with weights"
    circle = AdjectiveCircle.first
    circle_path = File.expand_path('../data/circles.csv', __FILE__)

    modified = check_if_inputs_modified(circle, circle_path)
    if modified
      attributes = [
        :name_pair, 
        :size_weight,
        :size_sd, 
        :size_mean, 
        :distance_weight, 
        :distance_sd, 
        :distance_mean, 
        :overlap_weight, 
        :overlap_sd, 
        :overlap_mean, 
        :maps_to
      ]
      CSV.foreach(circle_path) do |row|
        content = {}
        inner_count = 0 
        row.each do |value|
          content[attributes[inner_count]] = value
          inner_count += 1
        end
        content[:version] = "1.0"
        circle = AdjectiveCircle.where(name_pair: content[:name_pair]).first_or_initialize(content)
        circle.update_attributes(content)
        puts "Circle created = #{circle.to_s}" 
        circle.save
      end
    end
  end
end
