class ActivityStreamSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :raw_data, :performed_at, :type, :description

end