module Permissions
  class AnonymousPermission < BasePermission
    def initialize(caller, target_user)
      super()
      allow @users, [:create]
    end
  end
end