require 'redis'
require 'json'
require 'tidepool_analyze'
Dir[File.expand_path('../persistence/*.rb', __FILE__)].each {|file| require file }

class ResultsCalculator
  include Sidekiq::Worker
   
  MAX_NUM_EVENTS = 10000
  CURRENT_ANALYSIS_VERSION = '1.0'
 
  def perform(game_id)
    key = "game:#{game_id}"
    game = Game.where('id = ?', game_id).first
    if game.nil?
      $redis.del(key)
      return
    end

    user_events = user_events_from_redis(key)
    if user_events.empty?
      if game.event_log
        # We are recalculating results
        user_events = game.event_log
      else
        # No User events collected either in Redis or in Postgres (from prior run)
        game.status = :no_results
        game.save
        logger.error("Game #{game_id} does not have any user_events collected.")
        return
      end
    end

    # result = game.result.nil? ? game.create_result : game.result
    game.event_log = user_events
    if game.save  
      # Make sure we don't lose the event results
      # It is safe to delete from Redis, they are saved in Postgres
      $redis.del(key)
    else
      logger.error("Game #{game_id} event_log not saved, user_events still in Redis")
      return
    end
    # analyze_dispatcher = TidepoolAnalyze::AnalyzeDispatcher.new(game.definition.stages, elements, circles)
    analyze_dispatcher = TidepoolAnalyze::AnalyzeDispatcher.new
    
    analysis_results = analyze_dispatcher.analyze(user_events, game.definition.score_names)

    game.definition.calculates.each do |calculation|
      klass_name = "Persist#{calculation.to_s.camelize}"
      begin
        persist_calculation = klass_name.constantize.new()
        persist_calculation.persist(game, analysis_results)
      rescue Exception => e
        game.status = :no_results
        game.save
        logger.error("Game #{game_id} cannot persist #{klass_name} calculation. #{e.message}")
        raise e
      end
    end    

    game.status = :results_ready
    game.save
  end

  def user_events_from_redis(key)
    # Get the user events for a given game
    user_events_json = $redis.lrange(key, 0, MAX_NUM_EVENTS)
    user_events = []
    user_events_json.each do |user_event| 
      user_events << JSON.parse(user_event)
    end
    user_events
  end

  # def circles
  #   circles = {}
  #   AdjectiveCircle.where(version: CURRENT_ANALYSIS_VERSION).each do |entry|
  #     circles[entry[:name_pair]] = ::OpenStruct.new(entry.attributes)
  #   end
  #   circles    
  # end

  # def elements
  #   elements = {}
  #   Element.where(version: CURRENT_ANALYSIS_VERSION).each do |entry|
  #     elements[entry[:name]] = ::OpenStruct.new(entry.attributes) 
  #   end
  #   elements
  # end
end
