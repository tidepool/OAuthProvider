class ResultSerializer < ActiveModel::Serializer
  attributes :id, :aggregate_results, :intermediate_results, :game_id

end