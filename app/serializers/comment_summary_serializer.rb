class CommentSummarySerializer < ActiveModel::Serializer
  include UserNameSerialize

  attributes :id, :user_id, :activity_record_id, :text, :user_name, :user_image, :updated_at


end