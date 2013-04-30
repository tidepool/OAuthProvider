class ResultSerializer < ActiveModel::Serializer
  attributes :id, :aggregate_results, :scores, :assessment_id

  has_one :profile_description
end