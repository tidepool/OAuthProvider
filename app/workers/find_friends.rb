require 'pipeliner'

class FindFriends
  include Sidekiq::Worker
  sidekiq_options :retry => 5, :backtrace => 5

  def perform(user_id, find_list)
    return if find_list.nil? || find_list.empty?
    find_list.each do | list_type, items |

      # First see if the users are in Tidepool database (TidePool members)
      look_up_key = "users:#{list_type}"
      existing_members, to_be_invited_list = lookup_friends(look_up_key, items)

      # Filter out the ones that are already the user_id's friends
      look_up_key = "friend_list_#{list_type}:#{user_id}"      
      pending_friends = filter_out_existing_friends(look_up_key, existing_members)

      # The pending_friends have not accepted our friendship yet so add them as pending in Redis
      add_friends_as_pending(user_id, pending_friends, list_type)
      
      # The to_be_invited_list is not in TidePool database, so we watch out for them till they join. 
      invite_friends(user_id, to_be_invited_list, list_type)
    end
    status_key = "find_status:#{user_id}"
    StatusService.update(status_key, "completed")  
  end

  # Checks if the find_list already exists 
  def lookup_friends(look_up_key, find_list)
    existing_members = []
    to_be_invited = []
    # To avoid roundtrips to Redis server we pipeline the results.
    ::RedisHelpers::Pipeliner.pipeline $redis do |pipe|
      find_list.each do |item|
        pipe.enqueue $redis.sismember(look_up_key, item) do |result|
          if result
            existing_members << item
          else
            to_be_invited << item
          end
        end
      end
    end
    return existing_members, to_be_invited
  end

  def filter_out_existing_friends(look_up_key, existing_members)
    pending_friends = []
    ::RedisHelpers::Pipeliner.pipeline $redis do |pipe|
      existing_members.each do |item|
        pipe.enqueue $redis.sismember(look_up_key, item) do |result|
          pending_friends << item if !result
        end
      end
    end
    pending_friends
  end

  def add_friends_as_pending(user_id, existing_friends, key_type)
    # Every TidePool member can have a pending friends list
    # Every TidePool member can be discovered through either their email or facebook_id
    # So every TidePool member have 2 pending friends lists depending on how they are discovered.
    # We know the user_id who discovered the TidePool member, so we add the user_id in those 2 pending lists
    # In this case we are adding each found user (existing_friends) and 
    # adding the user_id to their pending list.
    $redis.pipelined do 
      existing_friends.each do |item|
        key_name = "pending_#{key_type}:#{item}"
        $redis.sadd(key_name, user_id)
      end
    end
  end

  def invite_friends(user_id, find_list, key_type)
    $redis.pipelined do 
      find_list.each do |item|
        key_name = "invited_#{key_type}:#{item}"
        $redis.sadd(key_name, user_id)
      end
    end    
  end
end