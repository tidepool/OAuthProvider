Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], 
            :scope => 'email'

  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
  provider :fitbit, ENV['FITBIT_KEY'], ENV['FITBIT_SECRET']
end