class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :guest, :name, :display_name,
            :date_of_birth, :gender, :image, 
            :timezone, :locale, 
            :description, 
            :city, :state, :country, 
            :education, :referred_by, :handedness,
            :ios_device_token, :android_device_token, :is_dob_by_age

  has_many :authentications
  has_one :personality
  has_many :aggregate_results
end
