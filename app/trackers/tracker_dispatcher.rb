Dir[File.expand_path('../providers/*.rb', __FILE__)].each {|file| require file }
require File.expand_path('../errors.rb', __FILE__)

class TrackerDispatcher
  include Sidekiq::Worker
  sidekiq_options :retry => false, :backtrace => 5
   
  def perform(connection_id, provider=nil, updates=nil)
    logger.info("TrackerDispatcher called with #{connection_id}")
    if updates.nil?
      connection = Authentication.where(id: connection_id).first
      return if connection.nil? 
      synchronize_connection(connection)
    else
      # batch updates based on notifications
      return if provider.nil? || provider.empty? || updates.nil?
      batch_synchronize(provider, updates)
    end   
  end

  def synchronize_connection(connection)
    provider = connection.provider
    logger.info("Synchronizing #{provider} for #{connection.user_id}")

    klass_name = "#{provider.to_s.camelize}Tracker"
    tracker = klass_name.constantize.new(connection)
    tracker.synchronize
    logger.info("Synchronization successful for #{provider} for #{connection.user_id}")
    connection.sync_status = :synchronized
    connection.last_accessed = Time.zone.now
    connection.save!
  rescue Trackers::AuthenticationError => e
    connection.sync_status = :authentication_error
    connection.last_error = e.message
    connection.last_accessed = Time.zone.now
    connection.save
    logger.error("Provider #{provider} cannot authenticate - #{e.message}")
  rescue Exception => e
    connection.sync_status = :sync_error
    connection.last_error = e.message
    connection.last_accessed = Time.zone.now
    connection.save
    logger.error("Provider #{provider} cannot synchronize - #{e.message}")
  end

  def batch_synchronize(provider, updates)
    logger.info("Batch synchronizing #{provider}")

    klass_name = "#{provider.to_s.camelize}Tracker"
    klass_name.constantize.batch_update_connections(updates)
  end
end