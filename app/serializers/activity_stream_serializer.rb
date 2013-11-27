class ActivityStreamSerializer < ActiveModel::Serializer
  include UserNameSerialize
  
  attributes :id, :user_id, :raw_data, :performed_at, :type, :description, :user_name, :user_image 

end