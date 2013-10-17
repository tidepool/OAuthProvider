class SpeedAggregateResultSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :type, :scores, :high_scores
  
end