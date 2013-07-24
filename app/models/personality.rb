# == Schema Information
#
# Table name: personalities
#
#  id                     :integer          not null, primary key
#  profile_description_id :integer
#  user_id                :integer
#  game_id                :integer
#  big5_score             :text
#  holland6_score         :text
#  big5_dimension         :string(255)
#  holland6_dimension     :string(255)
#  big5_low               :string(255)
#  big5_high              :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#

class Personality < ActiveRecord::Base
  serialize :big5_score, JSON
  serialize :holland6_score, JSON

  belongs_to :profile_description    
  belongs_to :user
  belongs_to :game

end
