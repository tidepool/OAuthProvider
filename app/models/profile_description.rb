class ProfileDescription < ActiveRecord::Base
  attr_accessible :big5_dimension, :bullet_description, :code, :description, :holland6_dimension, :name, :one_liner, :logo_url

  serialize :description, JSON
  serialize :bullet_description, JSON

  has_many :users
  has_many :results
end
