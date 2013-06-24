module Permissions
  class RegisteredUserPermission < BasePermission
    def initialize(caller, target_user)
      super()
      if caller == target_user

        allow @games, :create
        allow @games, [:show, :update, :destroy] do |game|
          game.user_id == caller.id
        end    
        allow @games, [:latest] do |game|
          game.user_id == caller.id
        end

        allow @games, :index 

        allow @results, [:create, :show, :progress] do |game|
          game.user_id == caller.id 
        end

        allow @users, [:show, :create, :update, :destroy, :personality] do |user|
          user.id == caller.id 
        end

        allow @recommendations, [:latest, :career] 

        allow @preorders, :create
      end
    end
  end
end