class Device < ActiveRecord::Base
  include Paginate

  belongs_to :user
end
