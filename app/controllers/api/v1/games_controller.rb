class Api::V1::GamesController < Api::V1::ApiController
  doorkeeper_for :index, :show, :destroy, :update

  def index
    games = Game.includes(:definition).where('user_id = ?', target_user.id).order(:date_taken).load
    respond_to do |format|
      format.json { render :json => games, :each_serializer => GameSummarySerializer }
    end
  end

  def show 
    game = current_resource
    
    respond_to do |format|
      format.json { render :json => game }
    end
  end

  def latest 
    game = current_resource
    respond_to do |format|
      format.json { render :json => game }
    end
  end

  def create
    calling_ip = request.remote_ip
    definition = Definition.find_or_return_default(params[:def_id])
    game = Game.create_by_definition(definition, target_user, calling_ip)
    respond_to do |format|
      format.json { render :json => game }
    end
  end

  def update
    game = current_resource
    game.update_attributes(game_params)
    respond_to do |format|
      format.json { render :json => game}
    end
  end

  def destroy
    game = current_resource
    game.destroy
    respond_to do |format|
      format.json { render :json => {} }
    end
  end

  private

  def current_resource
    if params[:id]
      @current_resource ||= Game.includes(:definition, :result).find(params[:id])
    else
      resource_method = "find_#{params[:action]}".to_sym
      @current_resource ||= Game.send(resource_method, target_user) if Game.respond_to?(resource_method)  
    end
  end

  def game_params
    params.require(:game).permit(:stage_completed)  
  end
end
