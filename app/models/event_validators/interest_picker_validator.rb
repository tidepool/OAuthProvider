class InterestPickerValidator < BaseValidator
  def validate_level_summary(event)
    symbol_list = event['symbol_list']
    raise  Api::V1::UserEventValidatorError, "symbol_list is not provided or is not an array." if symbol_list.nil? || symbol_list.class != Array

    word_list = event['word_list']
    raise  Api::V1::UserEventValidatorError, "word_list is not provided or is not an array." if word_list.nil? || word_list.class != Array
  end
end