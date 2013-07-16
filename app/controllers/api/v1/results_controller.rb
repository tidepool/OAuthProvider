class Api::V1::ResultsController < Api::V1::ApiController
  doorkeeper_for :all
  respond_to :json

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
      elsif game && game.status.to_sym != :calculating_results
        game.status = :calculating_results
        game.save

        ResultsCalculator.perform_async(game.id)
        api_status = ApiStatus.new({
          state: :pending, 
          link: api_v1_user_game_progress_url,
          message: 'Starting to calculate results.'
          })
        response_body = api_status
        status = :accepted
      end
    else 
      # Called for a user
      user = target_user
      if params[:type]
        results = Result.where('user_id = ? and type = ?', user.id, params[:type]).order('time_played')
      else
        results = Result.where('user_id = ?', user.id).order('time_played')      
      end
      response_body = results
    end

    respond_to do |format|
      format.json { render :json => response_body, :status => status, :each_serializer => ResultSerializer}
    end    
  end

  def show
    result = Result.find(params[:id])
    respond_to do |format|
      format.json { render :json => result, :status => :ok}
    end
  end

  def progress
    game = Game.find(params[:game_id])

    api_status = response_for_status(game.status)
    respond_to do |format|
      format.json { render :json => api_status, 
        :status => :ok, :location => api_status.status[:link] }
    end
  end

  protected

  def response_for_status(status)
    api_status = nil
    case status.to_sym
    when :calculating_results
      api_status = ApiStatus.new(
        {
          state: :pending,
          link: api_v1_user_game_progress_url,
          message: 'Results are still being calculated.'
        })        
    when :results_ready
      api_status = ApiStatus.new(
        {
          state: :done,
          link: api_v1_user_game_results_url,
          message: 'Results are ready.'
        })        
    when :incomplete_results
      api_status = ApiStatus.new(
        {
          state: :error,
          link: api_v1_user_game_results_url,
          message: 'Error calculating results. Please try again later.'
        })        
    else
      logger.error("Game #{params[:game_id]} does not exist or unknown status.")
      api_status = ApiStatus.new(
        {
          state: :precondition_failed,
          link: '',
          message: 'Not allowed to call progress.'
        })
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
end