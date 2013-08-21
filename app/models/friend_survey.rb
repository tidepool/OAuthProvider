# == Schema Information
#
# Table name: friend_surveys
#
#  id         :integer          not null, primary key
#  game_id    :integer
#  answers    :text
#  calling_ip :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class FriendSurvey < ActiveRecord::Base
  serialize :answers, JSON


end
