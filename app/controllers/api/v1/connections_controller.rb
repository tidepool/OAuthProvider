class Api::V1::ConnectionsController < Api::V1::ApiController
  doorkeeper_for :all

  def index
    strategy_list = OmniAuth.all_strategies 

    # [0] OmniAuth::Strategies::Facebook < OmniAuth::Strategies::OAuth2,
    # [1] OmniAuth::Strategies::Twitter < OmniAuth::Strategies::OAuth,
    # [2] OmniAuth::Strategies::Fitbit < OmniAuth::Strategies::OAuth

    connections = []
    strategy_list.each do |strategy|
      provider = /(?<=^OmniAuth::Strategies::)\S*/m.match(strategy.to_s).to_s.downcase
      
      authentication = Authentication.find_by_provider_and_user(provider, target_user)
      activated = !authentication.nil? 
      connections << {
        provider: provider,
        activated: activated
      }
    end

    respond_to do |format|
      format.json { render :json => connections }
    end
  end

  def synchronize
    provider = params[:provider]
    connection = Authentication.find_by_provider_and_user(provider, target_user)
    if connection && connection.sync_status != :synchronizing
      connection.sync_status = :synchronizing
      connection.save

      TrackerDispatcher.perform_async(target_user.id)    

      api_status = ApiStatus.new({
        state: :pending, 
        link: api_v1_user_connection_progress_url(provider),
        message: "Starting to synchronize #{provider}"
        })
      response_body = api_status
      status = :accepted
    else
      if connection.nil?
        api_status = ApiStatus.new({
          status: :error,
          message: "Provider #{provider} connection is not active."
        })
        status = :bad_request
      elsif connection.sync_status == :synchronizing
        api_status = ApiStatus.new({
          state: :pending,
          message: "Synchronization is already in progress.",
          link: api_v1_user_connection_progress_url(provider),
        })
        status = :ok 
      else
        api_status = ApiStatus.new({
          status: :error,
          message: "Unknown error."          
          })
        status = :not_acceptable
      end
      response_body = api_status
    end

    respond_to do |format|
      format.json { render :json => response_body, :status => status }
    end    
  end

  def progress 
    provider = params[:provider]
    connection = Authentication.find_by_provider_and_user(provider, target_user)

    if connection
      api_status = response_for_status(connection.sync_status, provider)
      status = :ok
    else
      api_status = ApiStatus.new({
       status: :error,
       message: "Provider #{provider} connection is not active."       
        })
      status = :bad_request
    end
    respond_to do |format|
      format.json { render :json => api_status, 
        :status => status, :location => api_status.status[:link] }
    end

  end

  protected
  def current_resource
    target_user
  end

  def response_for_status(status, provider)
    api_status = nil
    case status.to_sym
    when :synchronizing
      api_status = ApiStatus.new({
        state: :pending,
        link: api_v1_user_connection_progress_url(provider),
        message: 'Synchronization is in progress.'
      })        
    when :synchronized
      api_status = ApiStatus.new({
        state: :done,
        message: 'Synchronization is complete.'
      })        
    when :sync_error
      api_status = ApiStatus.new({
        state: :error,
        message: 'Error synchronizing.'
      })         
    end
    api_status
  end
end