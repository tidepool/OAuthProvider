class InterestPickerValidator < BaseValidator
  def validate_level_summary(event)
    # Notice that there is a bug in JSON parsing in Rails, 
    # where if an array is sent as empty, it gets converted to nil. That's why we relaxed the validation
    # here and instead added more error checking in the analyzer.
    # https://github.com/rails/rails/issues/8832
    # https://github.com/rails/rails/pull/8862

    symbol_list = event['symbol_list']
    raise  Api::V1::UserEventValidatorError, "symbol_list is not provided or is not an array." if symbol_list && symbol_list.class != Array

    word_list = event['word_list']
    raise  Api::V1::UserEventValidatorError, "word_list is not provided or is not an array." if word_list &&  word_list.class != Array
  end
end