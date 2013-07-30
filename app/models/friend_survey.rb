class FriendSurvey < ActiveRecord::Base
  serialize :answers, JSON


end
