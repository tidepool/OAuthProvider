class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :guest, :name, :display_name,
            :date_of_birth, :gender, :image, 
            :timezone, :locale, 
            :description, 
            :city, :state, :country, 
            :education, :referred_by, :handedness,
            :ios_device_token, :android_device_token, :is_dob_by_age, 
            :aggregate_results

  has_many :authentications
  has_one :personality
  has_many :aggregate_results, serializer: AggregateResultSerializer
  
  def aggregate_results
    # The iOS client relied on the first aggregate_result being the 
    # SpeedAggregateResult. For backwards compatibility, we are doing this hack!
    # TODO: Remove after the first iOS app is phased out!

    new_results = []
    other_results = []
    results = object.aggregate_results
    results.each do |result|
      if result.type == 'SpeedAggregateResult'
        new_results << result
      else
        other_results << result
      end
    end
    new_results.concat(other_results)
  end
end
