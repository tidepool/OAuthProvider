# == Schema Information
#
# Table name: definitions
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  stages       :text
#  instructions :text
#  end_remarks  :text
#  icon         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  score_names  :text
#  calculates   :text
#  result_view  :string(255)
#  unique_name  :string(255)
#

Dir[File.expand_path('../generators/*.rb', __FILE__)].each {|file| require file }

class Definition < ActiveRecord::Base
  serialize :stages, JSON
  serialize :score_names, JSON
  serialize :calculates, JSON
  
  def self.default
    definition = self.where(unique_name: 'baseline').first 
  end

  def self.same_as_game(game_id)
    game = Game.find(game_id)
    game.definition
  end

  def stages_from_stage_definition
    result = []
    self.stages.each do |stage|
      generator_name = stage['view_name']
      klass_name = "#{generator_name.camelize}Generator"
      generator = klass_name.constantize.new(stage)
      result << generator.generate
    end  
    result
  end
end
