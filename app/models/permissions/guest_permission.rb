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

  class GuestPermission < BasePermission
    def initialize(caller, target_user)
      super()
      if caller == target_user      
        allow @games, :create
        allow @games, [:update, :show] do |game|
          game.user_id == caller.id 
        end
        allow @games, [:latest, :latest_with_profile] do |game|
          game.user_id == caller.id 
        end

        allow @results, [:create, :show, :progress] do |game|
          game.user_id == caller.id 
        end

        allow @users, [:show, :update] do |user|
          user.id == caller.id 
        end
      end
    end
  end
end