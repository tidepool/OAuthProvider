class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :guest, :name, :display_name,
            :date_of_birth, :gender, :image, 
            :timezone, :locale, 
            :description, 
            :city, :state, :country,

  has_many :authentications
  has_one :profile_description
end
