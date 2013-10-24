class FriendSummarySerializer < ActiveModel::Serializer
  attributes :id, :name, :image, :uid

  def uid 
    uid = ""
    uid = object.uid if object.respond_to?(:uid)
    uid
  end
end