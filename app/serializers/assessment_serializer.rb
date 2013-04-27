class AssessmentSerializer < ActiveModel::Serializer
  attributes :id, :date_taken, :stage_completed, :stages, :user_id, :status

  has_one :definition, embed: :objects

  # def guest_user
  #   object.user.nil? ? nil : object.user.guest
  # end

end
