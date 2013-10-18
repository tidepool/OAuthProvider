RSpec.configure do |config|
  config.before(:suite) do
    # DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner[:active_record].strategy = :transaction
    DatabaseCleaner[:redis].strategy = :truncation
  end

  # config.before(:each, :js => true) do
  #   DatabaseCleaner[:active_record].strategy = :truncation
  #   DatabaseCleaner[:redis].strategy = :truncation
  # end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end