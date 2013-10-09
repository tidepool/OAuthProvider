class InvitedUser < ActiveRecord::Base
  belongs_to :inviter, :class_name => 'User'

end
