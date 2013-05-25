module Permissions
  class AdminPermission < BasePermission
    def initialize(caller, user)
      super()
      # Everything for now
      allow_all
    end
  end
end