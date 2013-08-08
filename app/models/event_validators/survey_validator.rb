class SurveyValidator < BaseValidator
  def validate_level_summary(event)
    data = event['data']
    raise  Api::V1::UserEventValidatorError, "Data is not provided or not an array." if data.nil? || data.class != Array
    required_keys = ['question_id', 'topic', 'answer']
    data.each do |item| 
      validate_keys(item, required_keys)
    end
  end
end