module Permissions
  class RegisteredUserPermission < BasePermission
    def initialize(caller, target_user)
      super()
      if caller == target_user

        allow :games, :create
        allow :games, [:show, :update, :destroy] do |game|
          game.user_id == caller.id
        end    
        allow :games, [:latest] do |game|
          game.user_id == caller.id
        end

        allow :games, :index 

        allow :results, :index 

        allow :results, [:show, :progress] do |item|
          if item.class == Game
            item.user_id == caller.id 
          elsif item.class == Result
            item.user_id == caller.id
          end
        end

        allow :users, [:show, :create, :update, :destroy, :personality] do |user|
          user.id == caller.id 
        end

        allow :recommendations, [:latest, :career, :emotion, :actions] 

        allow :preferences, [:show, :create, :update, :description]

        allow :preorders, :create

        allow :connections, :index
      end
    end
  end
end