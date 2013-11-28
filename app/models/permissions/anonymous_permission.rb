module Permissions
  class AnonymousPermission < BasePermission
    def initialize(caller, target_user)
      super()
      allow :users, [:create]
      allow :users, [:reset_password]
      allow :friend_surveys, [:create, :results]
      allow :profile_description, [:show]

    end
  end
end