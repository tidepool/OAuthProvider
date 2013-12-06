module Permissions
  class RegisteredUserPermission < BasePermission
    def initialize(caller, target_user)
      super()
      if caller == target_user

        allow :games, :create
        allow :games, [:show, :update, :destroy, :update_event_log] do |game|
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

        allow :users, [:create, :update, :destroy, :personality, :reset_password, :invite_friends] do |user|
          user.id == caller.id 
        end

        allow :users, :show 

        allow :recommendations, [:latest, :career, :emotion, :actions] 

        allow :preferences, [:show, :create, :update, :description]

        allow :preorders, :create

        allow :connections, [:index, :synchronize, :progress, :destroy]

        allow :activities, :index

        allow :sleeps, :index

        allow :friend_surveys, [:create, :results]

        allow :friends, [:index, :accept, :find, :pending, :invite, :reject, :unfriend]

        allow :leaderboards, [:global, :friends]

        allow :activity_stream, [:index]

        allow :comments, [:index, :show, :destroy, :create, :update]

        allow :highfives, [:index, :create, :destroy]

        allow :profile_description, [:show]

        allow :devices, [:index, :show, :destroy, :create, :update]
      end
    end
  end
end