class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :guest, :name, :display_name,
            :date_of_birth, :gender, :image, 
            :timezone, :locale, 
            :description, 
            :city, :state, :country, 
            :education, :referred_by, :handedness

  has_many :authentications
  has_one :personality
end
