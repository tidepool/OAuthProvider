Dir[File.expand_path('../providers/*.rb', __FILE__)].each {|file| require file }
require File.expand_path('../errors.rb', __FILE__)

class TrackerDispatcher
  include Sidekiq::Worker
   
  def perform(connection_id)
    logger.info("TrackerDispatcher called with #{connection_id}")
    connection = Authentication.where(id: connection_id).first
    return if connection.nil? 

    synchronize_connection(connection) 
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
end