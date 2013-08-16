module SeedsHelper
  def check_if_inputs_modified(data, *inputs)
    updated_at = data.updated_at if !data.nil?
    if updated_at
      inputs.each do |input|
        input_modified_time = File.mtime(input)
        puts "Data: #{updated_at.to_s} Input: #{input_modified_time.to_s}"
        return true if (updated_at < input_modified_time)
      end
    else
      return true
    end  
    return false
  end

  def big5_whitelist
    whitelist = {
      'low_extraversion' => 'low_extraversion',
      'high_extraversion' => 'high_extraversion',
      'low_conscientiousness' => 'low_conscientiousness',
      'high_conscientiousness' => 'high_conscientiousness',
      'low_openness' => 'low_openness',
      'high_openness' => 'high_openness',
      'low_neuroticism' => 'low_neuroticism',
      'high_neuroticism' => 'high_neuroticism',
      'low_agreeableness' => 'low_agreeableness',
      'high_agreeableness' => 'high_agreeableness' }
  end

  def big5_traits_whitelist
    whitelist = {
      'extraversion' => 'extraversion',
      'conscientiousness' => 'conscientiousness',
      'openness' => 'openness',
      'neuroticism' => 'neuroticism',
      'agreeableness' => 'agreeableness',
    }
  end

  def holland6_whitelist
    whitelist = {
      'realistic' => 'realistic',
      'artistic' => 'artistic',
      'social' => 'social',
      'enterprising' => 'enterprising',
      'investigative' => 'investigative',
      'conventional' => 'conventional'
    }
  end

  def adjectives_whitelist
    whitelist = {
      'Sociable/Adventurous' => 'Sociable/Adventurous',
      'Self-Disciplined/Persistent' => 'Self-Disciplined/Persistent',
      'Anxious/Dramatic' => 'Anxious/Dramatic',
      'Curious/Cultured' => 'Curious/Cultured',
      'Cooperative/Friendly' => 'Cooperative/Friendly',
      'Self-Reflective/Reserved' => 'Self-Reflective/Reserved',
      'Disorganized/Unconventional' => 'Disorganized/Unconventional',
      'Calm/Consistent' => 'Calm/Consistent',
      'Adamant/Focused' => 'Adamant/Focused',
      'Independent/Aloof' => 'Independent/Aloof',
      'Mechanical/Hands-on' => 'Mechanical/Hands-on',
      'Creative/Intuitive' => 'Creative/Intuitive',
      'Teacher/Helpful' => 'Teacher/Helpful',
      'Persuasive/Enthusiastic' => 'Persuasive/Enthusiastic',
      'Inquisitive/Analytical' => 'Inquisitive/Analytical',
      'Detail-Oriented/Thorough' => 'Detail-Oriented/Thorough'
    }
  end

  def emo_whitelist 
    whitelist = {
      'amused' => 'amused',
      'anger' => 'anger',
      'awe' => 'awe',
      'boredom' => 'boredom',
      'confused' => 'confused',
      'contentment' => 'contentment',
      'coyness' => 'coyness',
      'desire_food' => 'desire_food',
      'desire_sex' => 'desire_sex',
      'disgust' => 'disgust',
      'embarrassment' => 'embarrassment',
      'fear' => 'fear',
      'happiness' => 'happiness',
      'interest' => 'interest',
      'pain' => 'pain',
      'pride' => 'pride',
      'relief' => 'relief',
      'sadness' => 'sadness',
      'shame' => 'shame',
      'surprise' => 'surprise',
      'sympathy' => 'sympathy',
      'triumph' => 'triumph',
      'flagged_result1' => 'flagged_result1'
    }
  end

  def emo_factor_whitelist
    whitelist = {
      'factor1' => 'factor1',
      'factor2' => 'factor2',
      'factor3' => 'factor3',
      'factor4' => 'factor4',
      'factor5' => 'factor5'      
    }
  end

  def speed_archetype_whitelist
    whitelist = {
      'falcon' => 'falcon',
      'cheetah' => 'cheetah',
      'antelope' => 'antelope',
      'cat' => 'cat',
      'wolf' => 'wolf',
      'dog' => 'dog',
      'crow' => 'crow',
      'gorilla' => 'gorilla',
      'dolphin' => 'dolphin'
    }
  end
end
