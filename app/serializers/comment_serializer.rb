class CommentSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :activity_record_id, :text, :updated_at


end