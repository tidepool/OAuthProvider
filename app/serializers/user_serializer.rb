class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :guest, :name

end
