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
      game.event_log = {}
      game.status = :not_started
    end    
  end

  def self.find_latest(target_user)
    game = Game.where('user_id = ?', target_user.id).order(:date_taken).last
  end

  def all_events_received?
    all_exist = true
    num_stages = self.stages ? self.stages.length : 0
    raise ActiveRecord::RecordInvalid, "Game has no stages, #{num_stages}" if num_stages <= 0

    if self.event_log.nil? || self.event_log.empty?
      all_exist = false
    else
      (0...num_stages).each do | stage_no |
        if !self.event_log.has_key?(stage_no.to_s)
          all_exist = false
          break
        end
      end
    end
    all_exist
  end

  def update_event_log(new_event_log)
    raise ArgumentError, "Event log is empty." if new_event_log.nil? || new_event_log.empty?
    current_log = self.event_log
    current_log = {} if current_log.nil?
    if new_event_log.is_a?(Array)
      new_event_log.each { | event_log_entry | add_event_log_entry(event_log_entry, current_log) }
    else
      add_event_log_entry(new_event_log, current_log)
    end
    
    self.event_log = current_log
    self.save!
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

  protected

  def add_event_log_entry(event_log_entry, current_log)
    if event_log_entry['stage'] && ( !event_log_entry.has_key?('event_type') || !event_log_entry.has_key?('events'))
      # Trying to delete an entry
      stage_to_delete = event_log_entry['stage'].to_s
      current_log.delete(stage_to_delete)
    else
      validate(event_log_entry)
      stage = event_log_entry['stage'].to_s
      current_log[stage] = event_log_entry
    end
  end

  def validate(event_log_entry)
    level_type = event_log_entry['event_type']
    raise Api::V1::UserEventValidatorError, 'Module info missing.' if level_type.nil?

    klass_name = "#{level_type.camelize}Validator"
    validator = klass_name.constantize.new(event_log_entry)
    validator.validate
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
