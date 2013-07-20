require 'clockwork'
require './config/boot'
require './config/environment'

include Clockwork
 
handler do |job|
  # do something
  puts "Running #{job}"
  last_accessed = Time.zone.now - 2.hours
  Authentication.where('last_accessed < ? or last_accessed = ?', last_accessed, nil).limit(1000) do |authentication|
    puts "Dispatching #{authentication.email}"
    TrackerDispatcher.perform_async(authentication.user_id)
  end 
end
 
every(1.minute, 'update_trackers')