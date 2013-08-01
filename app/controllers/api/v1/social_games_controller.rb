class Api::V1::SocialGamesController < Api::V1::ApiController
  doorkeeper_for :index, :show, :destroy, :update
  rescue_from Api::V1::SocialResultsNotReadyError, with: :results_not_ready


  def create
    calling_ip = request.remote_ip
    game_setup = SocialGameSetup.setup_game(params[:def_id], target_user, calling_ip, params[:host_game_id])
  
    respond_to do |format|
      format.json { render({ json: game_setup, meta: {} }.merge(api_defaults)) }
    end
  end

  def update
    social_game = current_resource
    social_game.update_attributes(social_game_params)
    respond_to do |format|
      format.json { render({ json: game, meta: {} }.merge(api_defaults)) }
    end    
  end

  def result
    games_completed = Game.where(status: 'results_ready', social_game_id: params[:id]).all

    result_threshold = (current_resource.participants_expected * 0.6).ceil  # 60% of participants need to complete the game
    if games_completed.length >= result_threshold
      
    else
      raise SocialResultsNotReadyError, "Games completed are not over the required threshold, waiting for more games to be completed."
    end     
  end

  protected

  def current_resource
    @current_resource ||= SocialGame.params[:id]
  end

  def social_game_params
    params.require(:social_game).permit(:participants_expected)
  end

  def results_not_ready
    api_status = Hashie::Mash.new({
      code: 4000,
      message: exception.message
    })
    http_status = :not_found   
    respond_with_error(api_status, http_status)     
  end
end