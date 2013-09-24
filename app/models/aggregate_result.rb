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

  # def calculate_daily(new_value)
  #   daily_total = self.scores['daily_total'] || 0
  #   daily_data_points = self.scores['daily_data_points'] || 0
  #   daily_data_points += 1
  #   daily_average = daily_total.to_f / daily_data_points.to_f
  #   daily_trend =  new_value / daily_average
  #   daily_total += new_value

  #   return daily_total, daily_data_points, daily_trend
  # end


  # def calculate_trend(date, new_value)
  #   last_updated_str = nil
  #   last_updated_str = self.scores['last_updated'] if self.scores
  #   if last_updated_str.nil? || last_updated_str.empty?
  #     # Make it anything but today
  #     last_updated_str = (Date.current - 5.days).to_s
  #   end

  #   last_updated = Date.parse(last_updated_str)
  #   last_value = 0
  #   last_value = self.scores['last_value'].to_i if self.scores

  #   # The results (activities/sleeps) can come in multiple times during a day 
  #   # For activities we need to take the last activity update for the day to find 
  #   # the trend from the previous day.
  #   # Or 

  #   if date == last_updated
  #     trend = 0
  #     trend = self.scores['trend'].to_f if self.scores
  #   else
  #     if last_value == 0 
  #       trend = 999.99
  #     else
  #       trend = (new_value - last_value).to_f / last_value.to_f
  #     end
  #   end

  #   return trend, new_value, date
  # end
end
