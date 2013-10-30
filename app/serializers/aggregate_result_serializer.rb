class AggregateResultSerializer < ActiveModel::Serializer
  include EmoBadgeSerialize
  include SpeedAggregateBadgeSerialize

  attributes :id, :user_id, :type, :scores, :high_scores, :badge

  def badge
    badge = {}
    if object.type == "EmoAggregateResult" || object.type == "AttentionAggregateResult"
      badge = badge_for_score(object.last_value)
    elsif object.type == "SpeedAggregateResult"
      badge = badge_for_desc_id(object.last_value)
    end
    badge
  end

end