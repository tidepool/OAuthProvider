# == Schema Information
#
# Table name: sleeps
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  date_recorded  :date             not null
#  data           :hstore
#  goals          :hstore
#  sleep_activity :text
#  provider       :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

class Sleep < ActiveRecord::Base
  belongs_to :user
  serialize :sleep_activity, JSON
  store_accessor :data, :total_minutes_asleep, :total_minutes_in_bed

  def total_minutes_asleep=(value)
    super(value.to_i)
  end

  def total_minutes_asleep
    super.to_i
  end

  def total_minutes_in_bed=(value)
    super(value.to_i)
  end

  def total_minutes_in_bed
    super.to_i
  end
end
