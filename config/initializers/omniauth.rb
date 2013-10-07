Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], 
            :scope => 'email'

  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
  provider :fitbit, ENV['FITBIT_KEY'], ENV['FITBIT_SECRET'], :setup => lambda{|env| env['omniauth.strategy'].options[:authorize_params] = { :display => 'touch'} }
  provider :jawbone, ENV['JAWBONE_KEY'], ENV['JAWBONE_SECRET'],
            :scope => 'extended_read location_read friends_read mood_read mood_write move_read move_write sleep_read sleep_write meal_read meal_write weight_read weight_write cardiac_read cardiac_write generic_event_read generic_event_write'
end