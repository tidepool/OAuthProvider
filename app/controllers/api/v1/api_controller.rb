class Api::V1::ApiController < ApplicationController
  before_filter :authorize

  class UnauthorizedError < StandardError
  end

  protected

  def caller
    if doorkeeper_token
      @caller ||= User.includes(:profile_description).find(doorkeeper_token.resource_owner_id)
    else
      @caller = nil
    end
  end

  def target_user
    @target_user ||= params[:user_id].nil? || params[:user_id] == '-' ? caller : User.find(params[:user_id])
  end

  def current_permission
    @current_permission ||= Permissions::permissions_for(caller)
  end

  def current_resource
    nil
  end

  def authorize
    if !current_permission.allow?(params[:controller], params[:action], current_resource)
      raise UnauthorizedError.new('Not Authorized')
    end
  end
end
