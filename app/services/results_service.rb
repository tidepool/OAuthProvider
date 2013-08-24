class ResultsService
  def logger 
    ::Rails.logger
  end

  def find_results_for_game(game)
    results = []

    case game.status.to_sym 
    when :results_ready
      results = Result.where(game_id: game.id)
      status = :ready  
    when :calculating_results
      results = []
      status = :in_progress
    else
      results = []
      calculate_results(game)
      status = :started_calculation
    end
    return results, status
  end

  def find_results_for_user(user, result_type=nil, is_daily=false)
    if result_type
      results = Result.where('user_id = ? and type = ?', user.id, result_type).order('time_played')
    else
      results = Result.where('user_id = ?', user.id).order('time_played')      
    end

    response = results
    if is_daily
      daily_results = {}

      results.each do | result |
        day = result.time_played.strftime("%m/%d/%Y")
        daily_results[day] ||= []
        daily_results[day] << result
      end
      response = daily_results.values
    end
    response
  end

  def calculate_results(game)
    raise Api::V1::PreconditionFailedError, "All events for the game have not been received!" unless game.all_events_received?   
    game.status = :calculating_results
    game.save!

    ResultsCalculator.perform_async(game.id)    
  end
end