# == Schema Information
#
# Table name: measurements
#
#  id            :integer          not null, primary key
#  user_id       :integer          not null
#  date_recorded :date             not null
#  data          :hstore
#  goals         :hstore
#  details       :text
#  provider      :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

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
