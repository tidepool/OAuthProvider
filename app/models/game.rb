# == Schema Information
#
# Table name: games
#
#  id              :integer          not null, primary key
#  date_taken      :datetime
#  definition_id   :integer
#  user_id         :integer
#  stages          :text
#  stage_completed :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  status          :string(255)
#  calling_ip      :string(255)
#  event_log       :text
#  last_error      :text
#  name            :string(255)
#

class Game < ActiveRecord::Base
  serialize :stages, JSON
  serialize :event_log, JSON

  # Game status: :not_started, :calculating_results, :results_ready, :incomplete_results
  # status, is only used in calculating the results for a game.
  # It cannot be set publicly from the API, that may cause race conditions.
  # Use the helper methods: in_progress?, completed? for figuring out game status during gameplay.
                  
  belongs_to :user
  belongs_to :definition
  has_many :results
  has_many :friend_surveys

  # after_update do |game|
  #   unless game.game_completed?
  #     # We should not allow any more status changes based on stage_completed after the game is completed
  #     # That can potentially create race conditions.
  #     if game.stages && game.stages.length > 0
  #       game.status = :in_progress if game.stage_completed == 0
  #       game.status = :completed if (game.stage_completed == game.stages.length - 1)
  #       game.save
  #     end
  #   end
  # end

  def self.create_by_definition(definition, target_user, calling_ip = nil)
    raise ArgumentError.new('No definition specified') if definition.nil?
    raise ArgumentError.new('Requires a target user') if target_user.nil?   

    create! do |game|
      game.definition = definition
      game.name = definition.unique_name  # Denormolizing the unique_name of the definition
      game.stages = definition.stages_from_stage_definition
      game.user = target_user
      game.calling_ip = calling_ip
      game.date_taken = Time.zone.now # Always use Time.zone not Time
      game.stage_completed = -1
      game.status = :not_started
    end    
  end

  def self.find_latest(target_user)
    game = Game.where('user_id = ?', target_user.id).order(:date_taken).last
  end

  def results_calculated?
    self.status.to_sym == :results_ready 
  end

  def in_progress?
    self.stage_completed > -1 
  end

  def completed?
    self.stages && self.stages.length > 0 && self.stage_completed == self.stages.length - 1  
  end

  # def calculates_personality?
  #   self.definition.persist_as_results.index("profile") != nil
  # end

  # def self.find_latest_with_profile(target_user)
  #   definitions = Definition.where("calculates like '%profile%'").all
  #   query = (definitions.reduce("") { |out, definition| out + "definition_id = #{definition.id} or " }).chomp(" or ")
  #   game = Game.includes(:definition, :result).joins(:definition).where("(#{query}) and user_id = ? and status = 'results_ready'", target_user.id).order(:date_taken).last
  # end
end
