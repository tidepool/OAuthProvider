class AttentionResultSerializer < ActiveModel::Serializer
  include AttentionBadgeSerialize

  attributes :id, :game_id, :user_id, :type, :attention_score, 
            :time_played, :time_calculated, 
            :calculations, :badge

  def badge
    badge_for_score(object.attention_score)
  end        
end