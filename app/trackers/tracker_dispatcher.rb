require 'redis'
require 'json'
Dir[File.expand_path('../providers/*.rb', __FILE__)].each {|file| require file }

class TrackerDispatcher
  include Sidekiq::Worker
   
  RETRY_COUNT = 3

  def perform(user_id)
    user = User.where(id: user_id).first
    return if user.nil? || user.authentications.nil?

    supported_providers = {
      fitbit: true,
      facebook: false,
      twitter: false
    }
    user.authentications.each do | connection |
      provider = connection.provider
      if supported_providers[provider.to_sym]
        klass_name = "#{provider.to_s.camelize}Tracker"
        begin
          tracker = klass_name.constantize.new(user, connection)
          tracker.synchronize
          connection.sync_status = :synchronized
          connection.last_accessed = Time.zone.now
          connection.save!
        rescue Exception => e
          connection.sync_status = :sync_error
          connection.save
          logger.error("Provider #{provider} cannot synchronize - #{e.message}")
        end
      end         
    end
  end
end