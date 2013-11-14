class Api::V1::LeaderboardsController < Api::V1::ApiController
  doorkeeper_for :all

  def global
    game_name = params[:game_name]
    lb_service = LeaderboardService.new(game_name, nil)
    api_status, leaders = lb_service.global_leaderboard(params)

    response = {
      data: leaders,
      status: api_status
    }
    respond_to do |format|
      format.json { render( json: response.to_json ) }
    end
  end

  def friends
    game_name = params[:game_name]
    lb_service = LeaderboardService.new(game_name, target_user.id)
    api_status, leaders = lb_service.friends_leaderboard(params)

    response = {
      data: leaders,
      status: api_status
    }
    respond_to do |format|
      format.json { render( json: response.to_json ) }
    end
  end

  private
  def current_resource
    target_user
  end
end