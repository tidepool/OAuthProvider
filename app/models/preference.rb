class Preference < ActiveRecord::Base
  belongs_to :user

  def description
  end
end
