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
  store_accessor :data, :total_minutes_asleep, :total_minutes_in_bed, :efficiency, :minutes_to_fall_asleep,
      :start_time, :number_of_times_awake, :minutes_awake, :minutes_after_wake_up

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

  def efficiency=(value)
    super(value.to_i)
  end

  def efficiency
    super.to_i
  end

  def minutes_to_fall_asleep=(value)
    super(value.to_i)
  end

  def minutes_to_fall_asleep
    super.to_i
  end

  def number_of_times_awake=(value)
    super(value.to_i)
  end

  def number_of_times_awake
    super.to_i
  end

  def minutes_awake=(value)
    super(value.to_i)
  end

  def minutes_awake
    super.to_i
  end

  def minutes_after_wake_up=(value)
    super(value.to_i)
  end

  def minutes_after_wake_up
    super.to_i
  end
  
end
