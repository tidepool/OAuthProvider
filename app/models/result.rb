class Result < ActiveRecord::Base
  # attr_accessible :title, :body
  serialize :event_log, JSON
  serialize :intermediate_results, JSON
  serialize :final_results, JSON
  serialize :scores, JSON

  belongs_to :profile_descriptions
  belongs_to :assessments
  validates_associated :assessments
  
end
