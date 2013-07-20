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
