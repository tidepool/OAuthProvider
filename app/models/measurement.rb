class Measurement < ActiveRecord::Base
  belongs_to :user
  serialize :details, JSON
  store_accessor :data, :weight, :bmi
  store_accessor :goals, :weight_goal

  def weight=(value)
    super(value.to_i)
  end

  def weight
    super.to_i
  end

  def bmi=(value)
    super(value.to_f)
  end

  def bmi
    super.to_f
  end

  def weight_goal=(value)
    super(value.to_i)
  end

  def weight_goal
    super.to_i
  end

end
