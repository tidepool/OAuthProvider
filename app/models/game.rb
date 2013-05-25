class Game < ActiveRecord::Base
  serialize :stages, JSON

  # Game status: :not_started, :in_progress, :completed, :results_ready
                  
  belongs_to :user
  belongs_to :definition
  has_one :result, :inverse_of => :game, :dependent => :delete

  def self.create_by_definition(definition, target_user)
    raise ArgumentError.new('No definition specified') if definition.nil?
    raise ArgumentError.new('Requires a target user') if target_user.nil?   

    create! do |game|
      game.definition = definition
      game.stages = definition.stages_from_stage_definition
      game.user = target_user
      game.date_taken = Time.zone.now # Always use Time.zone not Time
      game.stage_completed = -1
      game.status = :not_started
    end    
  end

  def self.find_latest(target_user)
    game = Game.includes(:definition, :result).where('user_id = ?', target_user.id).order(:date_taken).last
  end

  def self.find_latest_with_profile(target_user)
    definitions = Definition.where("calculates like '%profile%'").all
    query = (definitions.reduce("") { |out, definition| out + "definition_id = #{definition.id} or " }).chomp(" or ")
    game = Game.includes(:definition, :result).joins(:definition).where("(#{query}) and user_id = ? and status = 'results_ready'", target_user.id).order(:date_taken).last
  end
end
