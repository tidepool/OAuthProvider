class PreferenceSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :data, :description

  def description
    object.class.description
  end
end