class HighfiveSummarySerializer < ActiveModel::Serializer
  include UserNameSerialize

  attributes :id, :user_id, :activity_record_id, :user_name, :user_image 


end