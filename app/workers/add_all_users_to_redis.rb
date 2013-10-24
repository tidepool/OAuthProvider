class AddAllUsersToRedis
  include Sidekiq::Worker
  sidekiq_options :retry => 5, :backtrace => 5

  def perform
    key = "users:emails"
    unless $redis.exists(key)
      email_list = []
      User.select(:id, :email).find_in_batches(batch_size: 1000) do |users| 
        user_emails = users.map { |user| user.email } 
        $redis.sadd(key, user_emails) 
      end
    end

    key = "users:facebook_ids"
    unless $redis.exists(key)
      Authentication.select(:id, :uid, :provider).find_in_batches(batch_size: 1000) do |authentications|
        user_ids = authentications.map do |authentication| 
          authentication.uid if authentication.provider == 'facebook'
        end
        $redis.sadd(key, user_ids)
      end
    end
  end
end