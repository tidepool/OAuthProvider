module Permissions
  class RegisteredUserPermission < BasePermission
    def initialize(caller, target_user)
      if caller == target_user
        allow :assessments, :create
        allow :assessments, [:show, :update, :destroy] do |assessment|
          assessment.user_id == caller.id
        end    
        allow :assessments, [:latest, :latest_with_profile] do |assessment|
          assessment.user_id == caller.id
        end

        allow :assessments, :index 

        allow :results, [:create, :show, :progress] do |assessment|
          assessment.user_id == caller.id 
        end

        allow :users, [:show, :create, :update, :destroy] do |user|
          user.id == caller.id 
        end
      end
    end
  end
end