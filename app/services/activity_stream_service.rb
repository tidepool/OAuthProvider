class ActivityStreamService
  include Paginate

  # http://www.quora.com/Redis/How-efficient-would-Redis-sorted-sets-be-for-a-news-feed-architecture
  
  def register_activity(user_id, activity_record)
    target_method = activity_record.target
    activity_id = activity_record.id

    self.send(target_method, user_id, activity_id) if self.respond_to?(target_method)
  end

  def read_activity_stream(user_id, params={})
    ranges = ranges(params)
    activity_ids = $redis.zrevrange activity_stream_key(user_id), ranges[:offset], ranges[:limit] - 1, with_scores: false 
    ranges[:total] = $redis.zcount activity_stream_key(user_id), "-inf", "+inf" 

    activities = ActivityRecord.where(id: activity_ids).to_a
    api_status = ActivityStreamService.generate_status(params, ranges)
    [activities, api_status]
  end
  
  private
  def send_all_friends(user_id, activity_id)
    friendships = Friendship.where(user_id: user_id).to_a
    score = Time.zone.now.to_i 
    older_score = (Time.zone.now - 3.months).to_i  # Remove items older than 3 months
    $redis.pipelined do
      friendships.each do |friendship|
        add_to_activity_stream(friendship.friend_id, score, older_score, activity_id)
      end
      add_to_activity_stream(user_id, score, older_score, activity_id)
    end
  end

  def add_to_activity_stream(user_id, score, old_threshold, activity_id)
    $redis.zadd activity_stream_key(user_id), score, activity_id
    $redis.zremrangebyscore activity_stream_key(user_id), "-inf", old_threshold.to_s
  end

  def ranges(params)
    ranges = {
      limit: (params[:limit] || 20).to_i, 
      offset: (params[:offset] || 0).to_i
    }
    raise Api::V1::NotAcceptableError, "Limit cannot be larger than 20." if params && params[:limit].to_i > 20
    ranges
  end

  def activity_stream_key(user_id)
    "activity_stream:#{user_id}"
  end

end
