class Result < ActiveRecord::Base
  # serialize :event_log, JSON
  serialize :intermediate_results, JSON  # deprecated DONOT use
  serialize :aggregate_results, JSON # deprecated DONOT use

  serialize :calculations, JSON


  # belongs_to :profile_description
  belongs_to :game
  belongs_to :user
  
end
