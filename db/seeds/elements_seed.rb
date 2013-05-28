require 'csv'

class ElementsSeed
  include SeedsHelper

  def create_seed
    element = Element.first
    element_path = File.expand_path('../data/element_weights.csv', __FILE__)

    modified = check_if_inputs_modified(element, element_path)
    if modified
      attributes = [
        :name,
        :weight_extraversion, 
        :weight_conscientiousness, 
        :weight_neuroticism, 
        :weight_openness, 
        :weight_agreeableness, 
        :standard_deviation,
        :mean]
      elements = []

      count = 0
      CSV.foreach(element_path) do |row|
        inner_count = 0
        row.each do |value|
          # Strip the "cf:" from the element name
          value = value[3..-1] if count == 0

          elements[inner_count] = {} if elements[inner_count].nil?
          elements[inner_count][attributes[count]] = value
          inner_count += 1
        end
        count += 1
      end
      puts 'Creating Elements'
      elements.each do |content|
        content[:version] = '1.0'
        element = Element.where(name: content[:name]).first_or_initialize(content)
        element.update_attributes(content)
        element.save
        print '.'
      end
    end
    puts
  end
end