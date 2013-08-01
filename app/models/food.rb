# == Schema Information
#
# Table name: foods
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

class Food < ActiveRecord::Base
  belongs_to :user
  serialize :details, JSON
  store_accessor :data, :calories, :water
  store_accessor :goals, :calories_goal

  def calories=(value)
    super(value.to_i)
  end

  def calories
    super.to_i
  end

  def water=(value)
    super(value.to_i)
  end

  def water
    super.to_i
  end

  def calories_goal=(value)
    super(value.to_i)
  end

  def calories_goal
    super.to_i
  end

end
