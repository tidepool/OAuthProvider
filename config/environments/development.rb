OAuthProvider::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger.const_get(ENV['LOG_LEVEL'] ? ENV['LOG_LEVEL'].upcase : 'DEBUG')

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # configure for Devise
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  # Without this Foreman does not show the buffer..
  # https://github.com/ddollar/foreman/wiki/Missing-Output
  $stdout.sync = true

  # config.eager_load is set to nil. Please update your config/environments/*.rb files accordingly:

  #   * development - set it to false
  #   * test - set it to false (unless you use a tool that preloads your test environment)
  #   * production - set it to true
  config.eager_load = false

  # http://coffeepowered.net/2013/08/02/ruby-prof-for-rails/
  config.middleware.insert 0, "Rack::RequestProfiler", :printer => ::RubyProf::CallTreePrinter

  config.cache_store = :dalli_store
end
