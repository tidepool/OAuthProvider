class Api::V1::FriendSurveysController < Api::V1::ApiController
  # doorkeeper_for :all
  rescue_from Api::V1::FriendSurveyNotReadyError, with: :survey_not_ready

  def create
    game_id = params[:game_id]
    answers = params[:friend_survey]
    calling_ip = request.remote_ip
    game = Game.find(game_id)
    friend_survey = game.friend_surveys.build()
    if friend_survey
      friend_survey.answers = answers
      friend_survey.calling_ip = calling_ip
      friend_survey.save!
    end
    respond_to do |format|
      format.json { render( { json:friend_survey, meta: {} }.merge(api_defaults))}
    end
  end

  def results
    game_id = params[:game_id]
    surveys = FriendSurvey.where(game_id: game_id)
    if surveys.nil? or surveys.length < 3
      raise Api::V1::FriendSurveyNotReadyError, "Survey results are not in yet."
    end

    big5_result = Result.where('type = ? and game_id = ?', 'Big5Result', game_id).first
    if big5_result.nil?
      raise Api::V1::FriendSurveyNotReadyError, "Your result is not calculated yet." 
    end

    my_results = big5_result.calculations["dimension_values"]
    others_results = calculate_from_surveys(surveys)

    final_result = Hashie::Mash.new({
      my_results: my_results,
      others_results: others_results
      })  
    respond_to do |format|
      format.json { render( { json:final_result, meta: {} }.merge(api_defaults))}
    end    
  end

  protected

  def survey_not_ready(exception)
    api_status = Hashie::Mash.new({
      code: 4000,
      message: exception.message
    })
    http_status = :not_found   
    respond_with_error(api_status, http_status)     
  end

  REVERSE_TOP = 8
  def calculate_from_surveys(surveys)
    # calculate the Big5 from high and low

    big5_results = []
    number_of_participants = surveys.length
    surveys.each do |survey|
      big5_result = {}
      if survey.answers.nil?
        number_of_participants = number_of_participants - 1
      else
        big5_result[:extraversion] = (survey.answers["high_extraversion"].to_f + (REVERSE_TOP - survey.answers["low_extraversion"].to_f)) / 2.0 
        big5_result[:conscientiousness] = (survey.answers["high_conscientiousness"].to_f + (REVERSE_TOP - survey.answers["low_conscientiousness"].to_f)) / 2.0    
        big5_result[:neuroticism] = (survey.answers["high_neuroticism"].to_f + (REVERSE_TOP - survey.answers["low_neuroticism"].to_f)) / 2.0    
        big5_result[:openness] = (survey.answers["high_openness"].to_f + (REVERSE_TOP - survey.answers["low_openness"].to_f)) / 2.0    
        big5_result[:agreeableness] = (survey.answers["high_agreeableness"].to_f + (REVERSE_TOP - survey.answers["low_agreeableness"].to_f)) / 2.0       
        big5_results << big5_result
      end
    end

    raise Api::V1::FriendSurveyNotReadyError, "Survey results missing data." if number_of_participants < 3
    
    # calculate total
    total = {}
    big5_results.each do |big5_result|
      big5_result.each do |key, value|
        total[key] = total[key] ? total[key] + value : value
      end
    end

    dimensions = [:extraversion, :conscientiousness, :neuroticism, :openness, :agreeableness]
    # calculate mean
    mean = {}
    dimensions.each do |dimension|
      mean[dimension] = total[dimension] / number_of_participants
    end

    mean

    # # calculate sd
    # sd = {}
    # big5_results.each do |big5_result|
    #   big5_result.each do |key, value|
    #     sd[key] = sd[key] ? sd[key] + (value - mean[key]) ** 2 : (value - mean[key]) ** 2
    #   end
    # end

    # dimensions.each do |dimension|
    #   sd[dimension] = Math.sqrt(sd[dimension] / number_of_participants)
    # end

    # # calculate zscores
    # zscores = []
    # big5_results.each do |big5_result|
    #   zscore = {}
    #   big5_result.each do |key, value|
    #     zscore[key] = (sd[key] == 0) ? 0 : (value - mean[key]) / sd[key]  
    #   end
    #   zscores << zscore
    # end

    # # average zscores
    # total_zscore = {}
    # zscores.each do |zscore|
    #   dimensions.each do |dimension|
    #     total_zscore[dimension] = total_zscore[dimension] ? total_zscore[dimension] + zscore[dimension] : zscore[dimension] 
    #   end
    # end
    # dimensions.each do |dimension|
    #   total_zscore[dimension] = total_zscore[dimension] / number_of_participants
    # end
    
    # # Find the lowest valued Big5 dimension
    # low_big5_value = 100000
    # total_zscore.each do |dimension, value|
    #   if value < low_big5_value
    #     low_big5_value = value
    #   end
    # end

    # # Adjust the numbers so that the big5 scores are distributed >= (1 * 10) 
    # # 1. Pick the min value
    # # 2. Add abs(min_value) + 1 to all values 
    # # 3. Multiply all values by 10 
    # adjust_by = low_big5_value.abs + 1
    # total_zscore.each do |dimension, value|
    #   total_zscore[dimension] = (value + adjust_by) * 10
    # end    

    # total_zscore
  end
end
