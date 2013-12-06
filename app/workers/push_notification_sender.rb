class PushNotificationSender
  include Sidekiq::Worker
  sidekiq_options :retry => 5, :backtrace => 5

  def perform(user_id, message)
    

  end

end