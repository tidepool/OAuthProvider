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
