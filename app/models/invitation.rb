class Invitation < ActiveRecord::Base
  belongs_to :user
  serialize :email_invite_list, JSON

end
