class Api::V1::ResultsController < Api::V1::ApiController
  doorkeeper_for :all
  rescue_from Api::V1::ResultCalculationError, with: :result_calculation_error

  def index 
    # results = Result.joins(:game).where('games.user_id' => target_user.id).order('games.date_taken')
    api_status = {}
    http_status = :ok

    # TODO : We need to fix this, this is UGLY!!!
    progress_url = api_v1_user_game_progress_url if params[:game_id]
    
    results_service = ResultsService.new(params, target_user, {
          progress: progress_url,
          results: api_v1_user_results_url } )
    results, api_status, http_status = results_service.find_results

    if params[:daily]
      # The below is because we are using ActiveModelSerialization
      # We don't have any control over the inner serializer (which is ArraySerializer in this case)
      # The array serializer by default inserts the data and status fields for each array inside the array
      # which is not what we want.
      # That's why I have this HACK below!

      response = {
        data:results,
        status: api_status
      }
      respond_to do |format|
        format.json { render( json: response.to_json ) }
      end
    else
      respond_to do |format|
        format.json { 
          render( { json: results, status: http_status, meta: api_status }.merge(api_defaults) )
        }
      end    
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
    logger.error("ResultCalculationError: #{exception.message}")
    http_status = :internal_server_error   
    respond_with_error(api_status, http_status)     
  end
end