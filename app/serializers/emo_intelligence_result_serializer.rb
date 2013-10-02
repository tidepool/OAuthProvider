class EmoIntelligenceResultSerializer < ActiveModel::Serializer
  attributes :id, :game_id, :user_id, :type, :eq_score, :corrects, :incorrects, 
            :time_elapsed, :instant_replays,  :time_played, :time_calculated, :reported_mood

end