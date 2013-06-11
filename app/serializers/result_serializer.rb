class ResultSerializer < ActiveModel::Serializer
  attributes :id, :aggregate_results, :scores, :game_id, :intermediate_results

end