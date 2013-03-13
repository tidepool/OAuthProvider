Dir[File.expand_path('../generators/*.rb', __FILE__)].each {|file| require file }

class Definition < ActiveRecord::Base
  serialize :stages, JSON
  attr_accessible :name, :stages, :instructions, :end_remarks, :experiment, :icon

  def self.find_or_return_default(def_id)
    begin
      definition = self.find(def_id)
    rescue ActiveRecord::RecordNotFound
      definition = self.first
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
