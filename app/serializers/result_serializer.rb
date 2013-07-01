class ResultSerializer < ActiveModel::Serializer
  attributes :id, :game_id, :user_id, :result_type, :score, :calculations, :time_played, :time_calculated

end