class Result < ActiveRecord::Base
  attr_accessible :assessment_id

  serialize :event_log, JSON
  serialize :intermediate_results, JSON
  serialize :aggregate_results, JSON
  serialize :scores, JSON

  belongs_to :profile_description
  belongs_to :assessment, :inverse_of => :result

  
end
