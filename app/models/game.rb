class Game < ActiveRecord::Base
  serialize :stages, JSON
  serialize :event_log, JSON

  # Game status: :not_started, :in_progress, :completed, :calculating_results, :results_ready, :no_results
                  
  belongs_to :user
  belongs_to :definition
  # has_one :result, :inverse_of => :game, :dependent => :delete
  has_many :results

  after_update do |game|
    if game.stage_completed == 0 && game.status.to_sym != :calculating_results
      game.status = :in_progress
    end
    if game.stages && (game.stage_completed == game.stages.length - 1) && game.status.to_sym != :calculating_results
      game.status = :completed
    end
  end

  def self.create_by_definition(definition, target_user, calling_ip = nil)
    raise ArgumentError.new('No definition specified') if definition.nil?
    raise ArgumentError.new('Requires a target user') if target_user.nil?   

    create! do |game|
      game.definition = definition
      game.stages = definition.stages_from_stage_definition
      game.user = target_user
      game.calling_ip = calling_ip
      game.date_taken = Time.zone.now # Always use Time.zone not Time
      game.stage_completed = -1
      game.status = :not_started
    end    
  end

  def self.find_latest(target_user)
    game = Game.includes(:definition).where('user_id = ?', target_user.id).order(:date_taken).last
  end

  def results_calculated?
    self.status.to_sym == :results_ready 
  end

  def calculates_personality?
    self.definition.calculates.index("profile") != nil
  end

  # def self.find_latest_with_profile(target_user)
  #   definitions = Definition.where("calculates like '%profile%'").all
  #   query = (definitions.reduce("") { |out, definition| out + "definition_id = #{definition.id} or " }).chomp(" or ")
  #   game = Game.includes(:definition, :result).joins(:definition).where("(#{query}) and user_id = ? and status = 'results_ready'", target_user.id).order(:date_taken).last
  # end
end
