class ResultSerializer < ActiveModel::Serializer
  attributes :id, :aggregate_results, :scores

  has_one :profile_description
end