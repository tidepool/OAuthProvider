require 'redis'
require 'json'
Dir[File.expand_path('../providers/*.rb', __FILE__)].each {|file| require file }
require File.expand_path('../errors.rb', __FILE__)

class TrackerDispatcher
  include Sidekiq::Worker
   
  def perform(user_id)
    logger.info("TrackerDispatcher called with #{user_id}")
    user = User.where(id: user_id).first
    return if user.nil? || user.authentications.nil?

    supported_providers = {
      fitbit: true,
      facebook: false,
      twitter: false
    }
    user.authentications.each do | connection |
      provider = connection.provider
      logger.info("Synchronizing #{provider} for #{user.id}")      
      synchronize_provider(provider, user, connection) if supported_providers[provider.to_sym]
    end
  end

  def synchronize_provider(provider, user, connection)
    klass_name = "#{provider.to_s.camelize}Tracker"
    tracker = klass_name.constantize.new(user, connection)
    tracker.synchronize
    logger.info("Synchronization successful for #{provider} for #{user.id}")
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