Dir[File.expand_path('../../services/providers/*.rb', __FILE__)].each {|file| require file }

class Subscriber
  include Sidekiq::Worker
  sidekiq_options :retry => 5, :backtrace => 5

  def perform(authentication_id)
    authentication = Authentication.find(authentication_id)
    user = authentication.user

    provider = authentication.provider
    begin
      klass_name = "#{provider.camelize}Registration"
      subscriber = klass_name.constantize.new(user, authentication)
      subscriber.create_subscription if subscriber.respond_to?(:create_subscription)
      authentication.save!
    rescue Exception => e
      Rails.logger.error("ProviderError: Could not populate from #{provider}. Error: #{e.message}")
      authentication.subscription_info = 'failed'
      authentication.save!
    end
  end
end