module Permissions
  class AnonymousPermission < BasePermission
    def initialize(caller, target_user)
      super()
      # Nothing for now!
    end
  end
end