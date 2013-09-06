class UserNewSerializer < ActiveModel::Serializer
  # A newly created user does not have the personality, aggregate_results, and authentications
  # so save time by not presenting those

  attributes :id, :email, :guest, :name, :display_name,
            :date_of_birth, :gender, :image, 
            :timezone, :locale, 
            :description, 
            :city, :state, :country, 
            :education, :referred_by, :handedness,
            :ios_device_token, :android_device_token, :is_dob_by_age

end