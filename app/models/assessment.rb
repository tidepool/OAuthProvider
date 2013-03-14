class Assessment < ActiveRecord::Base
  serialize :event_log, JSON
  serialize :intermediate_results, JSON
  serialize :stages, JSON
  serialize :aggregate_results, JSON

  # Assessment status: :not_started, :in_progress, :completed, :results_ready
  attr_accessible :date_taken, :score, :stages, :event_log, :intermediate_results, :stage_completed,
                  :aggregate_results, :results_ready, :big5_dimension, :holland6_dimension, :emo8_dimension, :status
  belongs_to :definition
  belongs_to :profile_description

  def self.create_with_definition_and_user(definition, user)
    create! do |assessment|
      assessment.definition = definition
      assessment.stages = definition.stages_from_stage_definition
      assessment.user_id = user.id if user
      assessment.date_taken = DateTime.now
      assessment.results_ready = false
      assessment.stage_completed = -1
      assessment.status = :not_started
    end
  end  
end
