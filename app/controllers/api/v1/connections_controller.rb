class Api::V1::ConnectionsController < Api::V1::ApiController
  doorkeeper_for :all
  rescue_from Api::V1::ExternalConnectionError, with: :external_connection_error
  rescue_from Api::V1::ExternalAuthenticationError, with: :external_authentication_error
  rescue_from Api::V1::SyncError, with: :sync_error
  
  def index
    strategy_list = OmniAuth.all_strategies 

    # [0] OmniAuth::Strategies::Facebook < OmniAuth::Strategies::OAuth2,
    # [1] OmniAuth::Strategies::Twitter < OmniAuth::Strategies::OAuth,
    # [2] OmniAuth::Strategies::Fitbit < OmniAuth::Strategies::OAuth

    connections = []
    strategy_list.each do |strategy|
      provider = /(?<=^OmniAuth::Strategies::)\S*/m.match(strategy.to_s).to_s.downcase
      
      # TODO : Calling the database in an inner loop is not a good idea!
      # See if caching works
      authentication = Authentication.where('provider = ? and user_id = ?', provider, target_user.id).first
      activated = !authentication.nil? 
      last_accessed = authentication ? authentication.last_accessed : nil
      last_error = authentication ? authentication.last_error : nil
      last_synchronized = authentication ? authentication.last_synchronized : nil
      sync_status = authentication ? authentication.sync_status : nil

      connections << {
        provider: provider,
        activated: activated,
        last_accessed: last_accessed,
        last_error: last_error,
        sync_status: sync_status, 
        last_synchronized: last_synchronized
      }
    end

    respond_to do |format|
      format.json { render({ json: connections, meta: {} }.merge(api_defaults)) }
    end
  end

  def synchronize
    provider = params[:provider]
    connection = Authentication.where('provider = ? and user_id = ?', provider, target_user.id).first
    if connection && connection.sync_status != 'synchronizing'
      connection.sync_status = 'synchronizing'
      connection.save

      TrackerDispatcher.perform_async(target_user.id)    

      api_status = Hashie::Mash.new({
        state: :pending, 
        link: api_v1_user_connection_progress_url,
        message: "Starting to synchronize #{provider}"
        })
      status = :accepted
    else
      if connection.nil?
        message = "Provider #{provider} connection is not activated yet. User needs to authenticate and activate."
        raise Api::V1::ExternalConnectionError, message 
      end

      if connection.sync_status == 'synchronizing'
        api_status = Hashie::Mash.new({
          state: :pending,
          message: "Synchronization is already in progress.",
          link: api_v1_user_connection_progress_url
        })
        status = :ok 
      end
    end

    respond_to do |format|
      format.json { render({ json: nil, status: status, meta: api_status, serializer: ResultSerializer }.merge(api_defaults)) }
    end    
  end

  def progress 
    provider = params[:provider]
    connection = Authentication.where('provider = ? and user_id = ?', provider, target_user.id).first

    if connection
      api_status = response_for_status(connection, provider)
      status = :ok
    else
      message = "Provider #{provider} connection is not activated yet. User needs to authenticate and activate."
      raise Api::V1::ExternalConnectionError, message 
    end
    respond_to do |format|
      format.json { render({ json: nil, status: status, meta: api_status, serializer: ResultSerializer, location: api_status.link }.merge(api_defaults)) }
    end

  end

  protected
  def current_resource
    target_user
  end

  def api_v1_user_connection_progress_url
    provider = params[:provider]
    user = params[:user_id]
    host = request.host
    protocol = request.protocol
    format = ''
    format = ".#{params[:format]}" if params[:format]
    "#{protocol}#{host}/api/v1/users/#{user}/connections/#{provider}/progress#{format}"
  end

  def response_for_status(connection, provider)
    status = connection.sync_status
    api_status = nil
    case status.to_sym
    when :synchronizing
      api_status = Hashie::Mash.new({
        state: :pending,
        link: api_v1_user_connection_progress_url,
        message: 'Synchronization is in progress.'
      })        
    when :synchronized
      api_status = Hashie::Mash.new({
        state: :done,
        message: 'Synchronization is complete.'
      })        
    when :sync_error
      message = "Provider #{provider} connection failed during synchronization. Error: #{connection.last_error}"
      raise Api::V1::SyncError, message
    when :authentication_error     
      message = "Provider #{provider} connection is denying access. Authentication may need renewal. Error: #{connection.last_error}"   
      raise Api::V1::ExternalAuthenticationError, message
    end
    api_status
  end

  private 

  def external_connection_error(exception)
    api_status = Hashie::Mash.new({
      code: 2001,
      message: exception.message
    })
    logger.error("ExternalConnectionError: #{exception.message}")
    http_status = :not_acceptable   
    respond_with_error(api_status, http_status)     
  end

  def external_authentication_error(exception)
    api_status = Hashie::Mash.new({
      code: 2002,
      message: exception.message
    })
    logger.error("ExternalAuthenticationError: #{exception.message}")
    http_status = :proxy_authentication_required   
    respond_with_error(api_status, http_status)     
  end

  def sync_error(exception)
    api_status = Hashie::Mash.new({
      code: 2003,
      message: exception.message
    })
    logger.error("SyncError: #{exception.message}")
    http_status = :bad_gateway   
    respond_with_error(api_status, http_status)     
  end
end
