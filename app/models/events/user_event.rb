class UserEvent
	extend ActiveModel::Naming
	include ActiveModel::Conversion
	def persisted?	
  	false
	end
	
	attr_accessor :game_id

	def self.cleanup(game_id)
		key = UserEvent.key(game_id)
		if $redis.exists(key)
			$redis.del(key)
		end
	end

	def self.key(game_id)
		"game:#{game_id}"
	end

	def initialize(data)
		@game_id = data[:game_id] || data[:game_id.to_s]
		raise ArgumentError("Invalid Event #{data}") if @game_id.nil?
		@event_data = data
	end

	def game_id=(value)
		@game_id = value
		if @event_data[:game_id]
			@event_data[:game_id] = value
		elsif @event_data["game_id"]
			@event_data["game_id"] = value
		end
	end

	def record
		key = UserEvent.key(self.game_id)
		$redis.rpush(key, @event_data.to_json)
	end


	# private 
	# def key
	# 	"game:#{self.game_id}"
	# end

end
