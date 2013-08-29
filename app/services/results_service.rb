class ResultsService
  def initialize(params, user, urls)
    @limit = params[:limit].to_i
    @offset = params[:offset].to_i
    if @limit && @offset && @limit != 0
      @paginate = true
    end
    @is_daily = params[:daily]
    @result_type = params[:type]
    @game_id = params[:game_id]
    @user = user
    @urls = urls
  end

  def logger 
    ::Rails.logger
  end

  def find_results
    http_status = :ok
    if @game_id
      game = Game.find(@game_id)
      results, api_status = find_results_for_game(game)
      if api_status[:state] == :pending
        http_status = :accepted
      end
    else
      results, api_status = find_results_for_user
    end

    return results, api_status, http_status
  end

  def find_results_for_game(game)
    results = []
    api_status = {}
    case game.status.to_sym 
    when :results_ready
      results = Result.where(game_id: game.id)
    when :calculating_results
      results = []
    else
      results = []
      calculate_results(game)
      api_status = Hashie::Mash.new({
        state: :pending, 
        link: @urls[:progress],
        message: 'Starting to calculate results.'
        })
    end
    return results, api_status
  end

  def find_results_for_user
    results = Result.where(user_id: @user.id)
    results = results.where(type: @result_type) if @result_type
    results = results.order('time_played')
    results = results.limit(@limit) if @paginate
    results = results.offset(@offset) if @paginate

    api_status = {}
    if @paginate
      next_offset = @offset + @limit 
      prev_offset = @offset - @limit 
      prev_offset = 0 if prev_offset < 0
      api_status = Hashie::Mash.new({
        'offset' => @offset,
        'limit' => @limit,
        'next' => "#{@urls[:results]}?offset=#{next_offset}&limit=#{@limit}",
        'prev' => "#{@urls[:results]}?offset=#{prev_offset}&limit=#{@limit}"
      })
    end
    response = results
    if @is_daily
      daily_results = {}

      results.each do | result |
        day = result.time_played.strftime("%m/%d/%Y")
        daily_results[day] ||= []
        daily_results[day] << result
      end
      response = daily_results.values
    end
    return response, api_status
  end

  def calculate_results(game)
    raise Api::V1::PreconditionFailedError, "All events for the game have not been received!" unless game.all_events_received?   
    game.status = :calculating_results
    game.save!

    ResultsCalculator.perform_async(game.id)    
  end
end