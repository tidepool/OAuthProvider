require 'pry' if Rails.env.test? || Rails.env.development?

class Assessment < ActiveRecord::Base
  serialize :event_log, JSON
  serialize :intermediate_results, JSON
  serialize :stages, JSON
  serialize :aggregate_results, JSON

  # Assessment status: :not_started, :in_progress, :completed, :results_ready
  attr_accessible :date_taken, :score, :intermediate_results, :stage_completed, :user_id,
                  :aggregate_results, :results_ready, :big5_dimension, :holland6_dimension, :emo8_dimension, :status
                  

  # IMPORTANT: user_id is specifically left as an id and not as a belongs_to relationship,
  #            In the future, the users table may live elsewhere.

  belongs_to :definition
  belongs_to :profile_description

  class UnauthorizedError < StandardError
  end

  def self.create_by_caller(definition, caller, user)
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

  def self.find_by_caller_and_user(id, caller, user)
    raise UnauthorizedError.new('Needs a caller') if caller.nil?
    assessment = Assessment.find(id)
    raise UnauthorizedError.new('Only admins or users themselves can see their assessments') unless assessment.user_id == user.id || caller.admin?
    assessment 
  end

  def self.find_all_by_caller_and_user(caller, user)
    raise UnauthorizedError.new('Needs a caller') if caller.nil?
    raise UnauthorizedError.new('Only admins or users themselves can see their assessments') unless caller.admin? || caller.id == user.id
    assessments = Assessment.includes(:definition).where('user_id = ?', user.id).order(:date_taken).all
  end

  def update_attributes_with_caller(attributes, caller)
    assessment_user_id = attributes[:user_id]
    if assessment_user_id
      assessment_user = User.where('id = ?', assessment_user_id).first
      self.add_to_user(caller, assessment_user)

      # Clear the :user_id, it should not be set directly
      attributes = attributes.except(:user_id)
    end

    update_attributes(attributes)
  end

  def add_to_user(caller, user)
    raise UnauthorizedError.new('Need a caller or user') if user.nil? || caller.nil?
    raise UnauthorizedError.new('Only admins or users themselves can add user') if user != caller && !caller.admin

    puts "Before Updating #{self.id} user_id = #{self.user_id}"
    self.user_id = user.id
    self.save
    puts "After Updating #{self.id} user_id = #{self.user_id}"

  end

  def results
    {
      :intermediate_results => self.intermediate_results,
      :aggregate_results => self.aggregate_results,
      :big5_dimension => self.big5_dimension,
      :holland6_dimension => self.holland6_dimension,
      :emo8_dimension => self.emo8_dimension
    }
  end    
end
