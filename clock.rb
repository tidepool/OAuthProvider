require 'clockwork'
require './config/boot'
require './config/environment'

include Clockwork
 
handler do |job|
  # do something
  puts "Running #{job}"
  ConnectionDispatcher.perform_async
end

update_interval = Integer(ENV["TRACKER_UPDATE_MINUTES"] || 10)
Rails.logger.info("Starting Clock with #{update_interval} minutes")
every(update_interval.minutes, 'update_trackers')