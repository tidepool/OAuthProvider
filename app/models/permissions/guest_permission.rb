module Permissions  
  class GuestPermission < BasePermission
    def initialize(caller, target_user)
      super()
      if caller == target_user      
        allow :games, :create
        allow :games, [:update, :show, :update_event_log] do |game|
          game.user_id == caller.id 
        end
        allow :games, [:latest, :latest_with_profile] do |game|
          game.user_id == caller.id 
        end

        allow :results, :index 

        allow :results, [:show, :progress] do |game|
          game.user_id == caller.id 
        end

        allow :users, [:show, :update, :personality] do |user|
          user.id == caller.id 
        end

        allow :friend_surveys, [:create, :results]
      end
    end
  end
end