# == Schema Information
#
# Table name: activities
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  date_recorded   :date             not null
#  type_id         :integer
#  name            :string(255)
#  data            :hstore
#  goals           :hstore
#  daily_breakdown :text
#  provider        :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class Activity < ActiveRecord::Base
  include Paginate
  
  belongs_to :user
  serialize :daily_breakdown, JSON

  store_accessor :data, :steps, :distance, :floors, :calories, :very_active_minutes, :elevation
  store_accessor :goals, :steps_goal, :distance_goal, :floors_goal, :calories_goal, :very_active_minutes_goal

  def steps=(value)
    super(value.to_i)
  end

  def steps
    super.to_i
  end

  def distance=(value)
    super(value.to_f)
  end

  def distance
    super.to_f
  end

  def floors=(value)
    super(value.to_i)
  end

  def floors
    super.to_i
  end

  def calories=(value)
    super(value.to_i)
  end

  def calories
    super.to_i
  end

  def very_active_minutes=(value)
    super(value.to_i)
  end

  def very_active_minutes
    super.to_i
  end

  def elevation=(value)
    super(value.to_i)
  end
  
  def elevation
    super.to_i
  end


  def steps_goal=(value)
    super(value.to_i)
  end

  def steps_goal
    super.to_i
  end

  def distance_goal=(value)
    super(value.to_f)
  end

  def distance_goal
    super.to_f
  end

  def floors_goal=(value)
    super(value.to_i)
  end

  def floors_goal
    super.to_i
  end

  def calories_goal=(value)
    super(value.to_i)
  end

  def calories_goal
    super.to_i
  end

  def very_active_minutes_goal=(value)
    super(value.to_i)
  end

  def very_active_minutes_goal
    super.to_i
  end

end
