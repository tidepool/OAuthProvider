Dir[File.expand_path('../../services/providers/*.rb', __FILE__)].each {|file| require file }

class Subscriber
  include Sidekiq::Worker
  sidekiq_options :retry => 5, :backtrace => 5

  def perform(user_id, provider)
    begin
      authentication = Authentication.where(user_id: user_id, provider: provider).first
      user = authentication.user

      klass_name = "#{provider.camelize}Registration"
      subscriber = klass_name.constantize.new(user, authentication)
      subscriber.create_subscription if subscriber.respond_to?(:create_subscription)
      authentication.save!
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error("SubscriberError: Could not find the connection for user #{user_id} and provider #{provider}. Error: #{e.message}")
    rescue Exception => e
      Rails.logger.error("SubscriberError: Could not subscribe to #{provider}. Error: #{e.message}")
      if authentication
        authentication.subscription_info = 'failed'
        authentication.save!
      end
    end
  end
end