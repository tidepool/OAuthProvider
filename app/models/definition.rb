Dir[File.expand_path('../generators/*.rb', __FILE__)].each {|file| require file }

class Definition < ActiveRecord::Base
  serialize :stages, JSON
  serialize :score_names, JSON
  serialize :calculates, JSON
  
  def self.find_or_return_default(def_id)
    if def_id.nil?
      def_id = 'baseline'
    end
    definition = self.where(unique_name: def_id).first
    if definition.nil?
      definition = self.where(unique_name: 'baseline').first 
    end
    definition
  end

  def stages_from_stage_definition
    result = []
    self.stages.each do |stage|
      module_name = stage['view_name']
      klass_name = "#{module_name.camelize}Generator"
      generator = klass_name.constantize.new(stage)
      result << generator.generate
    end  
    result
  end
end
