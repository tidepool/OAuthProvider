class AggregateResult < ActiveRecord::Base
  serialize :scores, JSON
  belongs_to :user

  def self.find_for_type(user_id, result_type)
    result = AggregateResult.where('user_id = ? and type = ?', user_id, result_type).first
  end  

  def calculate_trend(date, new_value)
    last_updated_str = nil
    last_updated_str = self.scores['last_updated'] if self.scores
    if last_updated_str.nil? || last_updated_str.empty?
      # Make it anything but today
      last_updated_str = (Date.current - 5.days).to_s
    end

    last_updated = Date.parse(last_updated_str)
    last_value = 0
    last_value = self.scores['last_value'].to_i if self.scores

    if date == last_updated
      trend = 0
      trend = self.scores['trend'].to_f if self.scores
    else
      if last_value == 0 
        trend = 999.99
      else
        trend = (new_value - last_value).to_f / last_value.to_f
      end
    end

    return trend, new_value, date
  end
end
