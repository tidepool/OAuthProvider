class ResultSerializer < ActiveModel::Serializer
  attributes :id, :game_id, :user_id, :type, :score, :calculations, :time_played, :time_calculated

end