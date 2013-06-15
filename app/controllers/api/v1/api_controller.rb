class Api::V1::ApiController < ApplicationController
  before_filter :authorize

  protected

  def caller
    if doorkeeper_token
      @caller ||= User.find(doorkeeper_token.resource_owner_id)
    else
      @caller = nil
    end
  end

  def target_user
    @target_user ||= params[:user_id].nil? || params[:user_id] == '-' ? caller : User.find(params[:user_id])
  end

  def current_permission
    @current_permission ||= Permissions.permission_for(caller, target_user)
  end

  def current_resource
    nil
  end

  def authorize
    
    if !current_permission.allow?(params[:controller], params[:action], current_resource)
      raise Api::V1::UnauthorizedError.new('Not Authorized')
    end
  end
end
