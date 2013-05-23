class Assessment < ActiveRecord::Base
  serialize :stages, JSON

  # Assessment status: :not_started, :in_progress, :completed, :results_ready
                  
  belongs_to :user
  belongs_to :definition
  has_one :result, :inverse_of => :assessment, :dependent => :delete

  class UnauthorizedError < StandardError
  end

  def self.create_by_caller(definition, target_user)
    raise ArgumentError.new('No definition specified') if definition.nil?
    raise ArgumentError.new('Requires a target user') if target_user.nil?   

    create! do |assessment|
      assessment.definition = definition
      assessment.stages = definition.stages_from_stage_definition
      assessment.user = target_user
      assessment.date_taken = DateTime.now
      assessment.stage_completed = -1
      assessment.status = :not_started
    end    
  end

  def self.find_latest(target_user)
    assessment = Assessment.includes(:definition, :result).where('user_id = ?', target_user.id).order(:date_taken).last
  end

  def self.find_latest_with_profile(target_user)
    definitions = Definition.where("calculates like '%profile%'").all
    query = (definitions.reduce("") { |out, definition| out + "definition_id = #{definition.id} or " }).chomp(" or ")
    assessment = Assessment.includes(:definition, :result).joins(:definition).where("(#{query}) and user_id = ? and status = 'results_ready'", target_user.id).order(:date_taken).last
  end
end
