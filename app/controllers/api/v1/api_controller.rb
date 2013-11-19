class Api::V1::ApiController < ApplicationController
  before_filter :authorize
  skip_before_action :verify_authenticity_token

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from Api::V1::UnauthorizedError, with: :unauthorized_access
  rescue_from Api::V1::PreconditionFailedError, with: :precondition_failed
  rescue_from Api::V1::NotAcceptableError, with: :unacceptable_request
  rescue_from ArgumentError, with: :record_invalid

  protected

  def caller
    token = Doorkeeper::OAuth::Token.from_bearer_authorization(request)
    if token
      @caller ||= Rails.cache.fetch("caller_#{token}", expires_in: 1.minutes) do
        # User.find(doorkeeper_token.resource_owner_id)
        User.joins(:access_token).where("oauth_access_tokens.token" => token).readonly(false).first
      end       
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
      raise Api::V1::UnauthorizedError, "User not allowed to call #{params[:controller]}, with #{params[:action]}."
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

  def respond_with_error(api_status, http_status)
    respond_to do |format|
      format.json { render({ json: nil, status: http_status, meta: api_status, serializer: ErrorSerializer }.merge(api_defaults)) }
    end
  end

  private
  def record_not_found(exception) 
    api_status = Hashie::Mash.new({
      code: 1001,
      message: exception.message
    })
    logger.error("ActiveRecord::RecordNotFound: #{exception.message}")
    http_status = :not_found   
    respond_with_error(api_status, http_status)     
  end

  def record_invalid(exception)
    api_status = Hashie::Mash.new({
      code: 1002,
      message: exception.message
    })
    logger.error("ActiveRecord::RecordInvalid: #{exception.message}")
    http_status = :unprocessable_entity   
    respond_with_error(api_status, http_status)     
  end

  def precondition_failed(exception)
    api_status = Hashie::Mash.new({
      code: 1003,
      message: exception.message
    })
    logger.error("PreconditionFailedError: #{exception.message}")
    http_status = :precondition_failed   
    respond_with_error(api_status, http_status)     
  end

  def unauthorized_access(exception)
    api_status = Hashie::Mash.new({
      code: 1000,
      message: exception.message
    })
    logger.error("UnauthorizedError: #{exception.message}")
    http_status = :unauthorized   
    respond_with_error(api_status, http_status)     
  end

  def unacceptable_request(exception)
    api_status = Hashie::Mash.new({
      code: 1004,
      message: exception.message
    })
    logger.error("UnacceptableRequest: #{exception.message}")
    http_status = :not_acceptable   
    respond_with_error(api_status, http_status)     
  end
end
