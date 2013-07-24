require 'redis'
require 'json'
require 'tidepool_analyze'
Dir[File.expand_path('../persistence/*.rb', __FILE__)].each {|file| require file }

class ResultsCalculator
  include Sidekiq::Worker
   
  MAX_NUM_EVENTS = 10000
  RETRY_COUNT = 3

  def perform(game_id)
    key = "game:#{game_id}"

    game = Game.where('id = ?', game_id).first
    if game.nil?
      $redis.del(key)
      return
    end

    # This retry is introduced to fix a problem we were having 
    # based on user events not arriving before the calculation begins.
    
    retries = 0
    while retries < RETRY_COUNT
      user_events = pull_events_from_redis(game, key)

      #TODO: Hate the nested if's, should refactor!
      if user_events && !user_events.empty?
        if store_events_in_event_log(game, user_events, key)
          analysis_results = analyze_results(game, user_events)
          if analysis_results
            game.status = persist_results(game, analysis_results)
          else
            game.status = :incomplete_results
          end        
        else
          game.status = :incomplete_results
          game.last_error = "Game #{game_id} cannot store events in the event_log."
        end        
      else
        game.status = :incomplete_results
        game.last_error = "Game #{game_id} does not have any events in Redis."
      end

      if game.status == :incomplete_results
        retries += 1
        logger.warn("Game #{game_id} is being retried, retry #{retries}")
      else
        game.last_error = ""
        break
      end
    end

    if game.status == :results_ready && game.event_log && !game.event_log.empty?
      $redis.del(key)
    else
      logger.error("Game #{game_id} events left in the Redis queue, needs to be cleaned up.")
    end

    unless game.save
      logger.error("Game #{game_id} cannot be saved post result calculation attempt.")
    end
  end

  def pull_events_from_redis(game, key)
    user_events = user_events_from_redis(key)
    if user_events.empty?
      # No User events collected either in Redis or in Postgres (from prior run)
      logger.error("Game #{game.id} does not have any user_events collected.")
    end
    user_events
  end

  def store_events_in_event_log(game, user_events, key)
    game.event_log = user_events
    if game.save  
      # # Make sure we don't lose the event results
      # # It is safe to delete from Redis, they are saved in Postgres
      # $redis.del(key)
      return true
    else
      logger.error("Game #{game.id} event_log not saved, user_events still in Redis")
      return false
    end
  end

  def analyze_results(game, user_events)
    analysis_results = nil
    begin
      analyze_dispatcher = TidepoolAnalyze::AnalyzeDispatcher.new
      analysis_results = analyze_dispatcher.analyze(user_events, game.definition.score_names)
    rescue Exception => e
      logger.error("Game #{game.id} cannot analyze calculation. #{e.message}")
      game.last_error = e.message
    end
    analysis_results
  end

  def persist_results(game, analysis_results)
    status = :results_ready
    if game.definition && game.definition.calculates
      game.definition.calculates.each do |calculation|
        klass_name = "Persist#{calculation.to_s.camelize}"
        begin
          persist_calculation = klass_name.constantize.new()
          persist_calculation.persist(game, analysis_results)
        rescue Exception => e
          logger.error("Game #{game.id} cannot persist #{klass_name} calculation. #{e.message}")
          status = :incomplete_results
          game.last_error = e.message
        end
      end 
    else
      logger.error("Game #{game.id} definition is not defined or missing calculates info.")
      status = :incomplete_results 
      game.last_error = "Game #{game.id} definition is not defined or missing calculates info."
    end
    status  
  end

  def user_events_from_redis(key)
    # Get the user events for a given game
    user_events_json = $redis.lrange(key, 0, MAX_NUM_EVENTS)
    user_events = []
    if user_events_json
      user_events_json.each do |user_event| 
        user_events << JSON.parse(user_event)
      end
    else
      logger.error("No events found in Redis for key #{key}.")
    end
    user_events
  end
end
