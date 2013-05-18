class DataSource < ActiveRecord::Base
  has_and_belongs_to_many :tracker_types
  
end
