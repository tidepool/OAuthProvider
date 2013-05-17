class Api::V1::ApiController < ApplicationController
  # before_filter :authorize

  protected

  def current_resource_owner
    if doorkeeper_token
      @current_resource_owner ||= User.includes(:profile_description).find(doorkeeper_token.resource_owner_id)
    else
      @current_resource_owner = nil
    end
  end

  def current_permission
    @current_permission ||= Permission.new(current_resource_owner)
  end

  def authorize
    
  end

end
