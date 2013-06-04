open_redis_url = ENV["OPENREDIS_URL"]
if open_redis_url.nil? 
  $redis = Redis.new
  # $redis = Redis.new(:host => ENV["REDIS_HOST"], :port => ENV["REDIS_PORT"])
  # $redis_analyze will subscribe to the ACTION messages 
  # DO NOT use $redis_analyze for anything other than subscribing, 
  # You will otherwise get an error: ERR only (P)SUBSCRIBE / (P)UNSUBSCRIBE / QUIT allowed in this context
  # $redis_analyze = Redis.new(:timeout => 0, :host => ENV["REDIS_HOST"], :port => ENV["REDIS_PORT"])
else
  $redis = Redis.connect :url => open_redis_url
  # uri = URI.parse(open_redis_url)
  # $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  # # $redis_analyze will subscribe to the ACTION messages 
  # # DO NOT use $redis_analyze for anything other than subscribing, 
  # # You will otherwise get an error: ERR only (P)SUBSCRIBE / (P)UNSUBSCRIBE / QUIT allowed in this context
  # # Commenting out :timeout=>0. Garantia Redis does not seem to like it
  # $redis_analyze = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end