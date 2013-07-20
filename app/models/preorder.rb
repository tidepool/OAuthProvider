# == Schema Information
#
# Table name: preorders
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Preorder < ActiveRecord::Base
  belongs_to :user
end
