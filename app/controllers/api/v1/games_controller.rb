class Api::V1::GamesController < Api::V1::ApiController
  doorkeeper_for :index, :show, :destroy, :update

  rescue_from Api::V1::UserEventValidatorError, with: :event_validation_error


  def index
    games = Game.where('user_id = ?', target_user.id).order(:date_taken).load
    respond_to do |format|
      format.json { render({ json: games, each_serializer: GameSummarySerializer, meta: {} }.merge(api_defaults)) }
    end
  end

  def show 
    game = current_resource
    respond_to do |format|
      format.json { render({ json: game, meta: {} }.merge(api_defaults)) }
    end
  end

  def latest 
    game = current_resource
    respond_to do |format|
      format.json { render({ json: game, meta: {} }.merge(api_defaults)) }
    end
  end

  def create
    calling_ip = request.remote_ip
    if params[:def_id]
      definition = Definition.where(unique_name: params[:def_id]).first      
      raise ActiveRecord::RecordNotFound, "Game definition not found." if definition.nil?
    elsif params[:same_as]
      definition = Definition.same_as_game(params[:same_as])
    else
      raise ArgumentError, "Game definition or same_as game not provided." 
    end
    game = Game.create_by_definition(definition, target_user, calling_ip)
    respond_to do |format|
      format.json { render({ json: game, meta: {} }.merge(api_defaults)) }
    end
  end

  def update
    game = current_resource
    game.update_attributes(game_params)
    respond_to do |format|
      format.json { render({ json: game, meta: {} }.merge(api_defaults)) }
    end
  end

  def update_event_log
    game = current_resource
    game.update_event_log(params[:event_log])
    api_status = Hashie::Mash.new({
      state: :event_log_updated,
      message: "Updated the event log for game #{game.id}" })

    # DONOT forget the serializer: GameSerializer, otherwise the meta: does not get serialized!
    respond_to do |format|
      format.json { render({ json: nil, meta: api_status, serializer: GameSerializer }.merge(api_defaults)) }
    end
  end

  def destroy
    game = current_resource
    game.destroy
    respond_to do |format|
      format.json { render({ json: game, meta: {} }.merge(api_defaults)) }
    end
  end

  private

  def current_resource
    if params[:id] || params[:game_id]
      game_id = params[:id] ? params[:id] : params[:game_id]
      @current_resource ||= Game.find(game_id)
    else
      resource_method = "find_#{params[:action]}".to_sym
      @current_resource ||= Game.send(resource_method, target_user) if Game.respond_to?(resource_method)  
    end
  end

  def game_params
    params.require(:game).permit(:stage_completed)  
  end

  def event_validation_error(exception)
    api_status = Hashie::Mash.new({
      code: 5000,
      message: exception.message
    })
    http_status = :conflict   
    respond_with_error(api_status, http_status)     
  end
end
