module Permissions  
  def self.permission_for(caller, target_user)
    if caller.nil?
      AnonymousPermission.new(caller, target_user)
    elsif caller.admin?
      AdminPermission.new(caller, target_user)
    elsif caller.guest?
      GuestPermission.new(caller, target_user)
    else
      RegisteredUserPermission.new(caller, target_user)
    end
  end

  class GuestPermission < BasePermission
    def initialize(caller, target_user)
      if caller == target_user      
        allow :assessments, :create
        allow :assessments, [:update, :show] do |assessment|
          assessment.user_id == caller.id 
        end
        allow :assessments, [:latest, :latest_with_profile] do |assessment|
          assessment.user_id == caller.id 
        end

        allow :results, [:create, :show, :progress] do |assessment|
          assessment.user_id == caller.id 
        end

        allow :users, [:show] do |user|
          user.id == caller.id 
        end
      end
    end
  end
end