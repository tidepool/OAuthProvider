class UserEvent
	extend ActiveModel::Naming
	include ActiveModel::Conversion
	def persisted?	
  	false
	end
	
	attr_accessor :assessment_id

	def self.cleanup(assessment_id)
		key = UserEvent.key(assessment_id)
		if $redis.exists(key)
			$redis.del(key)
		end
	end

	def self.key(assessment_id)
		"assessment:#{assessment_id}"
	end

	def initialize(data)
		@assessment_id = data[:assessment_id] || data[:assessment_id.to_s]
		raise ArgumentError("Invalid Event #{data}") if @assessment_id.nil?
		@event_data = data
	end

	def assessment_id=(value)
		@assessment_id = value
		if @event_data[:assessment_id]
			@event_data[:assessment_id] = value
		elsif @event_data["assessment_id"]
			@event_data["assessment_id"] = value
		end
	end

	def record
		key = UserEvent.key(self.assessment_id)
		$redis.rpush(key, @event_data.to_json)
	end


	# private 
	# def key
	# 	"assessment:#{self.assessment_id}"
	# end

end
