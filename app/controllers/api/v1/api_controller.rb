class Api::V1::ApiController < ApplicationController
  before_filter :authorize
  skip_before_action :verify_authenticity_token

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  protected

  def caller
    if doorkeeper_token
      @caller ||= User.find(doorkeeper_token.resource_owner_id)
    else
      @caller = nil
    end
  end

  def target_user
    @target_user ||= target_user_for(params[:user_id])
  end

  def target_user_for(user_id)
    user_id.nil? || user_id == '-' ? caller : User.find(user_id)
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

  def check_pagination
    @current_page = params[:page]    
  end

  def api_defaults
    {
      meta_key: 'status',
      root: 'data'
    }
  end

  private

  def record_not_found 
    
  end

  def record_invalid

  end
end
