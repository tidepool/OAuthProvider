class ActivitySerializer < ActiveModel::Serializer
  attributes :id, :user_id, :date_recorded, :type_id, :name, :data, :goals, :daily_breakdown, :provider, :created_at, :updated_at

end