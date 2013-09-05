Sidekiq.configure_server do |config|
  sidekiq_concurrency = ENV['SIDEKIQ_CONCURRENCY'] || 25
  database_url = ENV['DATABASE_URL']
  if database_url
    ENV['DATABASE_URL'] = "#{database_url}?pool=#{sidekiq_concurrency}"
    ActiveRecord::Base.establish_connection
  end
end