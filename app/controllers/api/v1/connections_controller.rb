module Api
  module V1
    class ExternalConnectionError < ::RuntimeError; end
    class ExternalAuthenticationError < ::SecurityError; end
    class ConnectionsController < Api::V1::ApiController
      doorkeeper_for :all
      rescue_from ExternalConnectionError, with: external_connection_error
      rescue_from ExternalAuthenticationError, with: external_connection_error
      
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
          connections << {
            provider: provider,
            activated: activated
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
            raise ExternalConnectionError, "Provider #{provider} connection is not active."
          elsif connection.sync_status == 'synchronizing'
            api_status = Hashie::Mash.new({
              state: :pending,
              message: "Synchronization is already in progress.",
              link: api_v1_user_connection_progress_url
            })
            status = :ok 
          else
            api_status = Hashie::Mash.new({
              status: :error,
              message: "Unknown error."          
              })
            status = :not_acceptable
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
          api_status = response_for_status(connection.sync_status, provider)
          status = :ok
        else
          api_status = Hashie::Mash.new({
           status: :error,
           message: "Provider #{provider} connection is not active."       
            })
          status = :bad_request
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

      def response_for_status(status, provider)
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
          api_status = Hashie::Mash.new({
            state: :error,
            message: 'Error synchronizing.'
          })     
        when :authentication_error        
          api_status = Hashie::Mash.new({
            state: :authentication_error,
            message: 'Error authenticating.'
          })     
        end
        api_status
      end

      private 

      def external_connection_error
        api_status = Hashie::Mash.new({
          code: 2001,
          message: "Provider #{provider} connection is not activated yet. User needs to authenticate and activate."
        })
        http_status = :bad_request   
        respond_with_error(api_status, http_status)     
      end

      def external_authentication_error
        api_status = Hashie::Mash.new({
          code: 2002,
          message: "Provider #{provider} connection is denying access. Authentication may need renewal."
        })
        http_status = :bad_request   
        respond_with_error(api_status, http_status)     
      end

      def respond_with_error(api_status, http_status)
        respond_to do |format|
          format.json { render({ json: nil, status: http_status, meta: api_status, serializer: ErrorSerializer }.merge(api_defaults)) }
        end
      end
    end
  end
end