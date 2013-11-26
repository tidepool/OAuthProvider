class ActivityRecord < ActiveRecord::Base
  belongs_to  :user
  serialize   :raw_data, JSON

  def record_usuals(raw_data)
    self.raw_data = raw_data
    self.performed_at = Time.zone.now # Always use Time.zone not Time
  end
end