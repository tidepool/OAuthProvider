module Permissions
  class RegisteredUserPermission < BasePermission
    def initialize(caller, target_user)
      super()
      if caller == target_user

        allow @games, :create
        allow @games, [:show, :update, :destroy] do |game|
          game.user_id == caller.id
        end    
        allow @games, [:latest, :latest_with_profile] do |game|
          game.user_id == caller.id
        end

        allow @games, :index 

        allow @results, [:create, :show, :progress] do |game|
          game.user_id == caller.id 
        end

        allow @users, [:finish_login]
        allow @users, [:show, :create, :update, :destroy] do |user|
          user.id == caller.id 
        end
      end
    end
  end
end