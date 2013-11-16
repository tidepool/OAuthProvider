class LeaderboardService
  include Paginate

  def initialize(game_name, user_id, caching_period=10.seconds)
    @game_name = game_name
    @user_id = user_id
    @caching_period = caching_period
  end

  def global_leaderboard(params={})
    ranges = ranges(params)
    leaders = $redis.zrevrange global_lb_key, ranges[:offset], ranges[:limit] - 1, with_scores: true    
    generate_output(leaders, ranges, params, global_lb_key)
  end

  def update_global_leaderboard(score)
    score = score.to_f

    # Update Redis
    old_score = $redis.zscore global_lb_key, @user_id.to_s
    old_score = old_score.to_f
    $redis.zadd global_lb_key, score, @user_id if score > old_score

    # Update Postgres
    lb_entry = Leaderboard.where(game_name: @game_name, user_id: @user_id).first_or_initialize
    old_score = lb_entry.score.to_f
    lb_entry.score = score if score > old_score 
    lb_entry.save!
  end

  def friends_leaderboard(params={})
    ranges = ranges(params)

    $redis.pipelined do 
      @friend_lb_exists = $redis.exists friend_lb_key
      @last_accessed = $redis.get last_accessed_key
    end
    initialize_friend_leaderboard unless @friend_lb_exists.value
    last_accessed_time = @last_accessed.value ? Time.zone.parse(@last_accessed.value) : Time.zone.now - 10.hours
    if Time.zone.now - last_accessed_time > @caching_period
      $redis.pipelined do     
        $redis.zinterstore friend_lb_key, [friend_lb_key, global_lb_key], aggregate: "max"
        @results = $redis.zrevrange friend_lb_key, ranges[:offset], ranges[:limit] - 1, with_scores: true
        $redis.set last_accessed_key, Time.zone.now.to_s
      end
    else
      $redis.pipelined do
        @results = $redis.zrevrange friend_lb_key, ranges[:offset], ranges[:limit] - 1, with_scores: true
        $redis.set last_accessed_key, Time.zone.now.to_s
      end
    end
    generate_output(@results.value, ranges, params, friend_lb_key)
  end

  private 
  def generate_output(results, ranges, params, key)
    leaderboard = merge_with_user_data(results)
    ranges[:total] = $redis.zcount key, "0", "+inf" 
    api_status = LeaderboardService.generate_status(params, ranges)
    [api_status, leaderboard]
  end

  def merge_with_user_data(leaders)
    user_ids = leaders.map { | leader | leader[0] }
    users = User.select(:id, :name, :email, :image).where(id: user_ids).to_a
    
    users_hash = {}
    users.each do |user|
      users_hash[user.id.to_s] = user
    end

    leaderboard = leaders.map do |leader|
      user_id = leader[0].to_s
      {
        id: users_hash[user_id].id,
        name: users_hash[user_id].name,
        email: users_hash[user_id].email,
        image: users_hash[user_id].image, 
        score: leader[1]
      }
    end
    leaderboard
  end

  def ranges(params)
    ranges = {
      limit: (params[:limit] || 10).to_i, 
      offset: (params[:offset] || 0).to_i
    }
    raise Api::V1::NotAcceptableError, "Limit cannot be larger than 10." if params && params[:limit].to_i > 10
    ranges
  end

  def initialize_friend_leaderboard
    # This is a 1-time expensive operation, if user has many friends. (1000s)
    # Assumption: 
    # The chances of user accumulating that many friends without leaderboard ever being called 
    # is very small.

    friends = Friendship.where(user_id: @user_id).select(:friend_id).to_a
    friends = friends.map { |friendship| [0.0, friendship.friend_id.to_s]}
    friends << [0.0, @user_id.to_s] # Don't forget yourself!
    result = $redis.zadd friend_lb_key, friends
    if result != friends.length 
      Rails.logger.error("Not all friends are added for user #{user_id}.")
    end    
  end

  def friend_lb_key
    "friend_lb:#{@game_name}:#{@user_id}"
  end

  def friend_lb_temp_key
    "friend_lb:#{@game_name}:temp_#{@user_id}"
  end

  def global_lb_key
    "global_lb:#{@game_name}"
  end

  def last_accessed_key
    "friend_lb:#{@game_name}:#{@user_id}:last"
  end
end