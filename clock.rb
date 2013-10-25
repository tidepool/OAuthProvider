require 'clockwork'
require './config/boot'
require './config/environment'

include Clockwork
 
handler do |job|
  # do something
  puts "Running #{job}"
  klass = job.constantize
  if klass && klass.respond_to?(:perform_async)
    klass.send(:perform_async)
  end
end

tracker_update_interval = Integer(ENV["TRACKER_UPDATE_MINUTES"] || 10)
# Rails.logger.info("Starting Clock with #{tracker_update_interval} minutes")

every(tracker_update_interval.minutes, 'ConnectionDispatcher')
