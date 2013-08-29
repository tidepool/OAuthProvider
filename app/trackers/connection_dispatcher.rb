require File.expand_path('../errors.rb', __FILE__)

class ConnectionDispatcher
  include Sidekiq::Worker
   
  def perform(options={})
    time_ago = options[:time_ago] || 8.hours
    last_accessed = Time.zone.now - time_ago

    connections(options) do |connection|
      should_sync = true
      should_sync = false if connection.last_accessed && connection.last_accessed > last_accessed
      # should_sync = false if connection.sync_status == "synchronizing"

      if should_sync
        logger.info "Dispatching #{connection.email}"
        TrackerDispatcher.perform_async(connection.id)
      end      
    end
  end

  def connections(options={}, &block)
    batch_size = options[:batch_size] || 1000
    supported_providers = options[:supported_providers] || ['fitbit']
    offset = 0
    loop do
      connections = Authentication.where(provider: supported_providers).offset(offset).limit(batch_size)
      break if connections.nil? || connections.empty?

      connections.each do | connection |
        yield connection
      end
      
      offset += batch_size
    end    
  end
end