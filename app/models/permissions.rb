module Permissions
  # def self.permission_for(caller, target_user)
  #   if caller.nil?
  #     AnonymousPermission.new(caller, target_user)
  #   elsif caller.admin?
  #     AdminPermission.new(caller, target_user)
  #   elsif caller.guest?
  #     GuestPermission.new(caller, target_user)
  #   else
  #     RegisteredUserPermission.new(caller, target_user)
  #   end
  # end
end