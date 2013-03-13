class AssessmentSerializer < ActiveModel::Serializer
  attributes :id, :guest_user, :date_taken, :stage_completed,  :aggregate_results, :stages,
             :results_ready, :big5_dimension, :holland6_dimension,
             :emo8_dimension

  has_one :profile_description
  has_one :user, embed: :ids
  has_one :definition, embed: :objects

  def guest_user
    object.user.nil? ? nil : object.user.guest
  end

end
