# == Schema Information
#
# Table name: preferences
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  type       :string(255)
#  data       :hstore
#  created_at :datetime
#  updated_at :datetime
#

class Preference < ActiveRecord::Base
  belongs_to :user

  def description
  end

  def update(update_data)
    return if update_data.nil? 

    # For some reason, PG's hstore does not allow you 
    # to modify the hash values and save it.
    # The modified values do not get saved
    # Workaround: Clone the data and re-set it.
    current_data = self.data.clone
    (update_data || {}).each do |name, value|
      current_data[name] = value
    end
    self.data = current_data

    save!
  end
end
