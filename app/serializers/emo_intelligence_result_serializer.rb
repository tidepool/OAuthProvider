class EmoIntelligenceResultSerializer < ActiveModel::Serializer
  include EmoBadgeSerialize

  attributes :id, :game_id, :user_id, :type, :eq_score, :corrects, :incorrects, 
            :time_elapsed, :instant_replays,  :time_played, :time_calculated, :reported_mood, 
            :calculations, :badge

  def badge
    badge_for_score(object.eq_score)
  end        
end