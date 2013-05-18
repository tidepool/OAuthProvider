class DataSourceSetting < ActiveRecord::Base
  belongs_to  :data_source
  belongs_to  :user
  
end
