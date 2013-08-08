class EmotionsCirclesTestValidator < BaseValidator
  def validate_level_summary(event)
    required_keys = ['data', 'self_coord']
    validate_keys(event, required_keys)

    self_circle = event['self_coord']
    raise Api::V1::UserEventValidatorError, "self_coord not provided" if self_circle.nil?

    keys = ['top', 'left']
    validate_keys(self_circle, keys)
    raise Api::V1::UserEventValidatorError, "self_coord size not provided" if self_circle['size'].nil? || self_circle['size'] == 0

    circles = event['data']
    raise Api::V1::UserEventValidatorError, "Data is not provided" if circles.nil? || circles.class != Array

    keys = ['trait1', 'size', 'width', 'left', 'top']
    circles.each do | circle |
      validate_keys(circle, keys)
    end
  end
end