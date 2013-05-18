class TrackerType < ActiveRecord::Base
  has_many :tracker_settings
  has_and_belongs_to_many :data_sources

end
