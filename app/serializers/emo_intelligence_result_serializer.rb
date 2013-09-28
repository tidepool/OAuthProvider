class EmoIntelligenceResultSerializer < ActiveModel::Serializer
  attributes :id, :game_id, :user_id, :type, :eq_score, :corrects, :incorrects, :time_played, :time_calculated

end