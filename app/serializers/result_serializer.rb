class ResultSerializer < ActiveModel::Serializer
  attributes :id, :aggregate_results, :scores, :game_id

  has_one :profile_description
end