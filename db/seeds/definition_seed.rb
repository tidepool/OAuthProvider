class DefinitionSeed 
  include SeedsHelper

  def create_seed
    puts 'Creating Definitions'
    # Load the default stages JSON file
    Dir[File.expand_path('../data/definitions/*.json', __FILE__)].each do |path|
      definition_json = IO.read(path)
      definition_attr = JSON.parse definition_json, :symbolize_names => true
      definition = Definition.where(unique_name: definition_attr[:unique_name]).first_or_initialize(definition_attr)
      definition.update_attributes(definition_attr)
      definition.save
      print '.'
    end
    puts
  end
end