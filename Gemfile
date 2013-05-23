source 'https://rubygems.org'

gem 'rails', '4.0.0.rc1'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
# gem 'sqlite3'

# Authentication:
# gem 'doorkeeper', '~> 0.6.7'
gem 'doorkeeper', :github => 'applicake/doorkeeper'  # For Rails 4rc1 support
gem 'omniauth'
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
  # gem 'twitter-bootstrap-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  # gem 'uglifier', '>= 1.0.3'
end

group :production do
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'oauth2'
  gem 'jazz_hands'
  gem 'dotenv-rails'
end

group :test, :development do
  gem 'factory_girl_rails'
end

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

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
