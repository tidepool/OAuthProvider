require 'clockwork'
require './config/boot'
require './config/environment'

include Clockwork
 
handler do |job|
  # do something
  puts "Running #{job}"
  last_accessed = Time.zone.now - 2.hours
  connections = Authentication.where('last_accessed < ? or last_accessed is NULL', last_accessed).limit(1000) 

  if connections 
    connections.each do |connection|
      puts "Dispatching #{connection.email}"
      TrackerDispatcher.perform_async(connection.user_id)
    end 
  end
end
 
every(2.hours, 'update_trackers')