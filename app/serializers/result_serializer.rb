class ResultSerializer < ActiveModel::Serializer
  attributes :id, :aggregate_results, :game_id

end