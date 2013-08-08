class ImageRankValidator < BaseValidator
  def validate_level_started(event)
    data = event['data']
    raise  Api::V1::UserEventValidatorError, "Data is not provided or not an array." if data.nil? || data.class != Array
    required_keys = ['elements', 'image_id']
    data.each do |item| 
      validate_keys(item, required_keys)
    end
  end

  def validate_level_summary(event)
    final_rank = event['final_rank']

    raise  Api::V1::UserEventValidatorError, "Final rank is not provided or not an array." if final_rank.nil? || final_rank.class != Array    
    final_rank.each do |item|
      raise Api::V1::UserEventValidatorError, "Item rank is not a valid number." if item.to_i < 0 || !is_numeric?(item)
    end
  end
end