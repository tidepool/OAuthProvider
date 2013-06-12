class ProfileDescription < ActiveRecord::Base
  serialize :description, JSON
  serialize :bullet_description, JSON

  # has_many :users
  # has_many :results
  has_many :personalities
end
