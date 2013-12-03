class ActivityStreamService
  include Paginate

  # http://www.quora.com/Redis/How-efficient-would-Redis-sorted-sets-be-for-a-news-feed-architecture

  # The activities in the set needs to be the same type.  
  def register_activity(user_id, activity_set)
    activity_set = Array(activity_set) # Make sure it is a set
    target_method = activity_set[0].target
    self.send(target_method, user_id, activity_set) if self.respond_to?(target_method)
  end

  def read_activity_stream(user_id, params={})
    ranges = ranges(params)
    activity_ids = $redis.zrevrange activity_stream_key(user_id), ranges[:offset], ranges[:limit] - 1, with_scores: false 
    activity_ids = activity_ids.map { |activity_id| activity_id.to_i }
    ranges[:total] = $redis.zcount activity_stream_key(user_id), "-inf", "+inf" 

    # activities = ActivityRecord.joins(:user).select("activity_records.*, users.email as user_email, users.name as user_name, users.image as user_image").where(id: activity_ids).to_a
    #   INNER JOIN "highfives" ON "highfives"."activity_record_id" = "activity_records"."id"
    query = %Q[
      SELECT ar.*, users.email as user_email, users.name as user_name, users.image as user_image, highfive.ct as highfive_count
      FROM "activity_records" ar
      INNER JOIN "users" ON "users"."id" = "ar"."user_id" 
      LEFT JOIN (
          SELECT activity_record_id, count(*) AS ct
          FROM "highfives"
          GROUP BY 1
        ) highfive ON highfive.activity_record_id = ar.id
      WHERE "ar"."id" IN #{activity_ids.to_s.gsub(/\[/, '(').gsub(/\]/, ')')}
    ]
    activities = ActivityRecord.find_by_sql(query)
    api_status = ActivityStreamService.generate_status(params, ranges)
    [activities, api_status]
  end
  
  def send_all_friends(user_id, activity_set)
    activity_set = Array(activity_set)
    friendships = Friendship.where(user_id: user_id).to_a

    $redis.pipelined do
      activity_set.each do |activity_record|
        activity_id = activity_record.id
        score = Time.zone.now.to_i 
        older_score = (Time.zone.now - 3.months).to_i  # Remove items older than 3 months
        friendships.each do |friendship|
          add_to_activity_stream(friendship.friend_id, score, older_score, activity_id)
        end
        add_to_activity_stream(user_id, score, older_score, activity_id)
      end
    end
  end

  private
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
