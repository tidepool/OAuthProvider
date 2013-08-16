class Api::V1::ResultsController < Api::V1::ApiController
  doorkeeper_for :all
  rescue_from Api::V1::ResultCalculationError, with: :result_calculation_error

  def index 
    # results = Result.joins(:game).where('games.user_id' => target_user.id).order('games.date_taken')
    response_body = {}
    status = :ok
    if params[:game_id]
      # Called for a specific game
      game = Game.find(params[:game_id])
      if game && game.results_calculated?
        results = Result.where(game_id: game.id)
        response_body = results
        api_status = {}
      elsif game && game.status.to_sym != :calculating_results
        raise Api::V1::PreconditionFailedError, "All events for the game has not been received!" unless game.all_events_received?
        
        game.status = :calculating_results
        game.save
        ResultsCalculator.perform_async(game.id)
        api_status = Hashie::Mash.new({
          state: :pending, 
          link: api_v1_user_game_progress_url,
          message: 'Starting to calculate results.'
          })
        response_body = []
        status = :accepted
      end
    else 
      # Called for a user
      user = target_user
      api_status = {}
      if params[:type]
        results = Result.where('user_id = ? and type = ?', user.id, params[:type]).order('time_played')
      else
        results = Result.where('user_id = ?', user.id).order('time_played')      
      end

      if params[:daily]
        daily_results = {}

        results.each do | result |
          day = result.time_played.strftime("%m/%d/%Y")
          daily_results[day] ||= []
          daily_results[day] << result
        end
        response_body = daily_results.values
      else
        response_body = results      
      end
    end

    render_hash = {  
      json: response_body, 
      status: status, 
      # each_serializer: ResultSerializer,
      meta: api_status 
      }
    if params[:daily]
      render_hash = {  
        json: response_body, 
        status: status, 
        meta: api_status 
        }
    end

    respond_to do |format|
      format.json { 
        render(render_hash.merge(api_defaults))
      }
    end    
  end

  def show
    result = Result.find(params[:id])
    respond_to do |format|
      format.json { 
        render({
          json: result, 
          status: :ok,
          meta: {}
          }.merge(api_defaults))
        }
    end
  end

  def progress
    game = Game.find(params[:game_id])

    api_status = response_for_status(game)
    respond_to do |format|
      format.json { 
        render({
          json: nil,
          status: :ok,
          serializer: ResultSerializer,
          location: api_status.link,
          meta: api_status
          }.merge(api_defaults))
      }
    end
  end

  protected

  def response_for_status(game)
    status = game.status
    api_status = nil
    case status.to_sym
    when :calculating_results
      api_status = Hashie::Mash.new(
        {
          state: :pending,
          link: api_v1_user_game_progress_url,
          message: 'Results are still being calculated.'
        })        
    when :results_ready
      api_status = Hashie::Mash.new(
        {
          state: :done,
          link: api_v1_user_game_results_url,
          message: 'Results are ready.'
        })        
    when :incomplete_results
      message = game.last_error
      logger.error("Api caught error: #{message}")
      raise Api::V1::ResultCalculationError, message 
    else
      logger.error("Game #{params[:game_id]} does not exist or unknown status.")
      raise Api::V1::PreconditionFailedError, "Game #{params[:game_id]} does not exist or unknown status."
    end
    api_status
  end  

  def current_resource 
    if params[:id]
      @result || Result.find(params[:id])
    elsif params[:game_id]
      @game ||= Game.find(params[:game_id]) 
    end
  end

  private

  def result_calculation_error(exception)
    api_status = Hashie::Mash.new({
      code: 3001,
      message: exception.message
    })
    http_status = :internal_server_error   
    respond_with_error(api_status, http_status)     
  end
end