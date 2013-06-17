require 'csv'

class CirclesSeed
  include SeedsHelper

  def create_seed
    circle = AdjectiveCircle.first
    circle_path = File.expand_path('../data/circles.csv', __FILE__)

    modified = check_if_inputs_modified(circle, circle_path)
    if true
      puts "Creating Circles"
      b5_whitelist = big5_traits_whitelist
      h6_whitelist = holland6_whitelist
      whitelist = b5_whitelist.merge(h6_whitelist)
      adj_whitelist = adjectives_whitelist 

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
        if whitelist[content[:maps_to]]
          content[:maps_to] = whitelist[content[:maps_to]]
        else
          puts "Wrong dimension: #{content[:maps_to]}"
          raise Exception.new
        end
        if adj_whitelist[content[:name_pair]]
          content[:name_pair] = adj_whitelist[content[:name_pair]]
        else
          puts "Wrong dimension: #{content[:name_pair]}"
          raise Exception.new
        end

        content[:version] = "1.0"
        circle = AdjectiveCircle.where(name_pair: content[:name_pair]).first_or_initialize(content)
        circle.update_attributes(content)
        circle.save
        print '.'
      end
    end
    puts
  end
end
