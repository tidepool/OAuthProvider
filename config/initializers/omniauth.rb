Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], 
            :scope => 'email'

  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
  provider :fitbit, ENV['FITBIT_KEY'], ENV['FITBIT_SECRET'], :setup => lambda{|env| env['omniauth.strategy'].options[:authorize_params] = { :display => 'touch'} }
  provider :jawbone, ENV['JAWBONE_KEY'], ENV['JAWBONE_SECRET'],
            :scope => 'extended_read location_read friends_read mood_read move_read sleep_read meal_read weight_read cardiac_read generic_event_read'
end