class AggregateResult < ActiveRecord::Base
  serialize :scores, JSON
  belongs_to :user

  def self.find_for_type(user_id, result_type)
    result = AggregateResult.where('user_id = ? and type = ?', user_id, result_type).first
  end  

  def calculate_trend(new_value, average)
    return 1.0 if average.nil? || average.to_f == 0.0 # If no average, yet, you will be 100%
    trend = (new_value.to_f - average.to_f) / average.to_f
  end
end
