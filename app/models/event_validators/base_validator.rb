class BaseValidator
  def initialize(event_log)
    @event_log = event_log
    @top_level_keys = ['event_type', 'stage', 'events']
    @events_keys = ['time']
    @expected_events = {
      'level_started' => false, 
      'level_completed' => false, 
      'level_summary' => false }
  end


  def validate
    @top_level_keys.each do | key |
      raise Api::V1::UserEventValidatorError, "#{key} not specified." unless @event_log.has_key?(key)
    end

    @event_log['events'].each do |event|
      validate_event(event)  
    end

    @expected_events.each do |expected_event, value|
      raise Api::V1::UserEventValidatorError, "Expected event #{expected_event} not found." if value == false
    end
    true
  end

  def validate_event(event)
    event_name = event['event']
    check_event_expected(event_name)

    event_validator = "validate_#{event_name}".to_sym
    if self.respond_to?(event_validator)
      self.send(event_validator, event)
    end

    validate_keys(event, @events_keys)
  end

  def check_event_expected(event_name)
    if @expected_events.has_key?(event_name)
      if @expected_events[event_name] == false
        @expected_events[event_name] = true
      else
        raise Api::V1::UserEventValidatorError, "Duplicate #{expected_event} specified."
      end
    end
  end

  def validate_keys(item, keys)
    keys.each do |key|
      raise Api::V1::UserEventValidatorError, "For a given hash, #{key} is not specified or value is nil." unless item.has_key?(key) && !item[key].nil?
    end       
  end

  def is_numeric?(input)
    input.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end
end