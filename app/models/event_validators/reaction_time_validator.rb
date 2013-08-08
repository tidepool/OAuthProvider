class ReactionTimeValidator < BaseValidator

  def validate_level_started(event)
    sequence_type = event['sequence_type']
    raise  Api::V1::UserEventValidatorError, "Sequence Type is not provided" if sequence_type.nil?

    data = event['data']
    raise  Api::V1::UserEventValidatorError, "Data is not provided" if data.nil? || data.class != Array
    data.each do |item| 
      raise Api::V1::UserEventValidatorError, "Data items for event #{event['event']} should be of type String" unless item.class == String
      raise Api::V1::UserEventValidatorError, "Data items for event #{event['event']} should be in the format of color:time_interval" if item.split(':').length != 2
    end
  end

  def validate_shown(event)
    required_keys = ['color', 'index']
    validate_keys(event, required_keys)
  end

  def validate_correct(event)
    required_keys = ['color', 'index']
    validate_keys(event, required_keys)
  end

  def validate_incorrect(event)
    required_keys = ['color', 'index']
    validate_keys(event, required_keys)
  end
end
