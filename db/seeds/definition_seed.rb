class DefinitionSeed 
  include SeedsHelper

  def create_seed
    puts 'Seeding the definitions'
    # Load the default stages JSON file
    Dir[File.expand_path('../data/definitions/*.json', __FILE__)].each do |path|
      definition_json = IO.read(path)
      definition_attr = JSON.parse definition_json, :symbolize_names => true
      definition = Definition.where(name: definition_attr[:name]).first_or_initialize(definition_attr)
      definition.update_attributes(definition_attr)
      puts "Saving #{path}"
      definition.save
    end
  end
end