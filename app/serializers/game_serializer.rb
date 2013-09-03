class GameSerializer < ActiveModel::Serializer
  attributes :id, :name, :date_taken, :stage_completed, :stages, :user_id, :status, :definition_id

  # has_one :definition, embed: :ids
  has_many :results
end
