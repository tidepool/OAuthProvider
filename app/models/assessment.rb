
class Assessment < ActiveRecord::Base
  serialize :event_log, JSON
  serialize :intermediate_results, JSON
  serialize :stages, JSON
  serialize :aggregate_results, JSON

  # Assessment status: :not_started, :in_progress, :completed, :results_ready
  attr_accessible :date_taken, :score, :stages, :event_log, :intermediate_results, :stage_completed,
                  :aggregate_results, :results_ready, :big5_dimension, :holland6_dimension, :emo8_dimension, :status,
                  :user_id

  # IMPORTANT: user_id is specifically left as an id and not as a belongs_to relationship,
  #            In the future, the users table may live elsewhere.

  belongs_to :definition
  belongs_to :profile_description

  class UnauthorizedError < StandardError
  end

  def self.create_or_find(definition, caller, user)
    raise ArgumentError.new('No definition specified') if definition.nil?

    if user && caller != user
      raise UnauthorizedError.new('Only admins or users themselves can add user') if caller && !caller.admin
      raise UnauthorizedError.new('Need a caller') if caller.nil?
    end

    create! do |assessment|
      assessment.definition = definition
      assessment.stages = definition.stages_from_stage_definition
      assessment.user_id = user.nil? ? 0 : user.id
      assessment.date_taken = DateTime.now
      assessment.results_ready = false
      assessment.stage_completed = -1
      assessment.status = :not_started
    end    
  end

  def add_to_user(caller, user)
    raise UnauthorizedError.new('Need a caller or user') if user.nil? || caller.nil?
    raise UnauthorizedError.new('Only admins or users themselves can add user') if user != caller && !caller.admin

    self.user_id = user.id
  end
end
