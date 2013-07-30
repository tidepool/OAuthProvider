source 'https://rubygems.org'
ruby "1.9.3"

gem 'rails', '4.0.0'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Authentication:
# gem 'doorkeeper', '~> 0.6.7'
gem 'doorkeeper', :github => 'applicake/doorkeeper'  # For Rails 4rc1 support
gem 'omniauth', :github => 'tidepool/omniauth' # We need a way to iterate over all providers
gem 'omniauth-facebook'
gem 'omniauth-fitbit'
gem 'omniauth-twitter'

# To support CORS
gem 'rack-cors', :require => 'rack/cors'

gem 'tidepool_analyze', :path => './lib/analyze'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # gem 'sass-rails',   '~> 3.2.3'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

end

group :production do
  gem 'newrelic_rpm'
end

group :teamcity do
  # The below debugger-ruby_core_source is a dependency 
  # of debugger gem and it is failing to install before 1.2.2
  # https://github.com/cldwalker/debugger/issues/12
  gem 'debugger-ruby_core_source', '~> 1.2.3'
end

group :development, :test, :teamcity do
  gem 'annotate', ">=2.5.0"
  gem 'rspec-rails'
  gem 'oauth2'
  gem 'jazz_hands'
  # gem 'dotenv-rails'
  # https://github.com/bkeepers/dotenv/commit/5084756968badfc1fd783242db093fb9996d6537
  gem 'dotenv-rails', :github => 'bkeepers/dotenv'
  gem 'factory_girl_rails'
end

# Pagination
gem 'kaminari'

# Cron replacement
gem 'clockwork'

# Data Sources
gem 'fitgem'

# API (Serializers)
gem "active_model_serializers", :github => "rails-api/active_model_serializers"

gem 'jquery-rails'

# Database
gem 'pg'
gem 'redis'

# Below are required for sidekiq and its web admin UI
gem 'sidekiq'
gem 'sinatra', require: false
gem 'slim'
gem 'foreman'

gem 'thin'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

