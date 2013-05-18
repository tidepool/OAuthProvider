class TrackerSetting < ActiveRecord::Base
  has_many    :trackers
  belongs_to  :tracker_type
  belongs_to  :user

end
