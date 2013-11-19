class AggregateResultSerializer < ActiveModel::Serializer
  include EmoBadgeSerialize
  include SpeedAggregateBadgeSerialize
  include AttentionBadgeSerialize

  attributes :id, :user_id, :type, :scores, :high_scores, :badge

  def badge
    # TODO: ActiveModelSerializer 0.9.0 changes the way serializers are assigned
    # Once that is stable, I will change this to inherit from AggregateResultSerializer, 
    # instead of the ugly hack below!!

    badge = {}
    if object.type == "EmoAggregateResult" 
      badge = badge_for_score(object.last_value)
    elsif object.type == "AttentionAggregateResult"
      badge = attention_badge_for_score(object.last_value)
    elsif object.type == "SpeedAggregateResult"
      badge = badge_for_desc_id(object.last_value)
    end
    badge
  end

end