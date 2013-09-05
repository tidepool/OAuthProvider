class GameNewSerializer < ActiveModel::Serializer
  attributes :id, :name, :date_taken, :stage_completed, :stages, :user_id, :status, :definition_id

end
