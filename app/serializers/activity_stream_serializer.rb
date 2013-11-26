class ActivityStreamSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :raw_data, :performed_at, :type, :description, :user_name, :user_image 

  def user_name
    if object.user_name.nil? || object.user_name.empty?
      object.user_email.split('@')[0]
    else
      object.user_name
    end
  end
end