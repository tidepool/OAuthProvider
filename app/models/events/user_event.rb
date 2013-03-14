class UserEvent
	extend ActiveModel::Naming
	include ActiveModel::Conversion
	def persisted?	
  	false
	end
	
	attr_accessor :assessment_id

	def initialize(data)
		@assessment_id = data[:assessment_id]
		raise ArgumentError("Invalid Event #{data}") if @assessment_id.nil?
		@event_data = data
	end

	def record
		$redis.rpush(key, @event_data.to_json)
	end

	private 
	def key
		"assessment:#{self.assessment_id}"
	end

end
