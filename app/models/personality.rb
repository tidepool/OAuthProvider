class Personality < ActiveRecord::Base
  serialize :big5_score, JSON
  serialize :holland6_score, JSON

  belongs_to :profile_description    
  belongs_to :user
  belongs_to :game

end
