require 'clockwork'
require './config/boot'
require './config/environment'

include Clockwork
 
handler do |job|
  # do something
  puts "Running #{job}"
  ConnectionDispatcher.perform_async
end
 
every(5.minutes, 'update_trackers')