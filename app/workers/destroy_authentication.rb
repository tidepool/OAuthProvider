Dir[File.expand_path('../../services/providers/*.rb', __FILE__)].each {|file| require file }

class DestroyAuthentication
  include Sidekiq::Worker
  sidekiq_options :retry => 5, :backtrace => 5

  def perform(user_id, provider)
    begin
      authentication = Authentication.where(user_id: user_id, provider: provider).first
      user = authentication.user
      klass_name = "#{provider.camelize}Registration"
      subscriber = klass_name.constantize.new(user, authentication)
      is_removed = true
      is_removed = subscriber.remove_subscription if subscriber.respond_to?(:remove_subscription)
      if is_removed
        authentication.destroy!
        Rails.logger.info("DestroyAuthenticationSuccess: #{user_id} unsubscribed from #{provider}.")
      else
        Rails.logger.error("DestroyAuthenticationError: #{user_id} cannot unsubscribe from #{provider}, authentication still exist.")
      end
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error("DestroyAuthenticationError: Could not find the connection for user #{user_id} and provider #{provider}. Error: #{e.message}")
    rescue Exception => e
      Rails.logger.error("DestroyAuthenticationError: Could not unsubscribe from #{provider}. Error: #{e.message}")
    end
  end
end