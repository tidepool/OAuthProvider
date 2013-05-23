module Permissions
  class AdminPermission < BasePermission
    def initialize(caller, user)
      # Everything for now
      allow_all
    end
  end
end