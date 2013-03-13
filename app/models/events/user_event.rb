module RecordEvent
	ACTION_EVENT_QUEUE = 'action_events'

	def record
		case @event_type.to_i
		when UserEvent::ANALYSIS_EVENT
			save_in_store
		when UserEvent::ACTION_EVENT
			publish_to_queue
		else
			# logger.info("Unknown Event Type: #{self.event_data}")
		end
	end

	private

	def save_in_store
		$redis.rpush(key, @event_data.to_json)
	end

	def publish_to_queue
		$redis.publish(ACTION_EVENT_QUEUE, @event_data.to_json)
	end

	def key
		"user:#{self.user_id}:test:#{self.assessment_id}"
	end
end

class UserEvent
	include RecordEvent
	extend ActiveModel::Naming
	include ActiveModel::Conversion
	def persisted?	
  	false
	end
	
	attr_accessor :user_id, :assessment_id, :event_type

	ANALYSIS_EVENT = 0
	ACTION_EVENT = 1

	def initialize(data)
		@user_id = data[:user_id]
		@assessment_id = data[:assessment_id]
		@event_type = data[:event_type]
		raise ArgumentError("Invalid Event #{data}") if @user_id.nil? || @assessment_id.nil? || event_type.nil? 
		@event_data = data
	end
end
