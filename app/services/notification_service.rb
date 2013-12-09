class NotificationService
  include Paginate

  def add_notification(user_id, notification, time=Time.zone.now)
    older_score = (time - 2.weeks).to_i 
    $redis.multi do
      $redis.zadd notifications_key(user_id), time.to_i, notification.to_json
      $redis.incr unread_notifications_key(user_id)
      $redis.zremrangebyscore notifications_key(user_id), "-inf", older_score.to_s
    end
  end

  def unread_count(user_id)
    $redis.get unread_notifications_key(user_id)
  end

  def clear_notifications(user_id, time=Time.zone.now)
    $redis.multi do
      $redis.set unread_notifications_key(user_id), 0
      $redis.set unread_reset_time_key(user_id), time.to_i
    end
  end

  def list_notifications(user_id, params={})
    ranges = ranges(params)
    last_reset_time = ($redis.get(unread_reset_time_key(user_id)) || 0).to_i
    ranges[:total] = $redis.zcount notifications_key(user_id), "0", "+inf" 

    notifications = $redis.zrevrange notifications_key(user_id), ranges[:offset], ranges[:limit] - 1, with_scores: true 
    response = []
    notifications.each do |notification, score|
      is_read = score.to_i < last_reset_time
      notification = JSON.parse(notification, symbolize_names: true)
      response << {
        message: notification[:alert] || notification.to_s,
        is_read: is_read
      }
    end

    api_status = NotificationService.generate_status(params, ranges)
    [response, api_status]
  end

  private
  def notifications_key(user_id)
    "notifications:#{user_id}"
  end

  def unread_notifications_key(user_id)
    "unread_notifications_count:#{user_id}"
  end

  def unread_reset_time_key(user_id)
    "unread_reset_time:#{user_id}"
  end

  def ranges(params)
    ranges = {
      limit: (params[:limit] || 20).to_i, 
      offset: (params[:offset] || 0).to_i
    }
    raise Api::V1::NotAcceptableError, "Limit cannot be larger than 20." if params && params[:limit].to_i > 20
    ranges
  end
end