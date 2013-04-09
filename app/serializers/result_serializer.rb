class ResultSerializer < ActiveModel::Serializer
  attributes :id, :final_results, :scores

  has_one :profile_description
end