require 'tidepool_analyze'
Dir[File.expand_path('../persistence/*.rb', __FILE__)].each {|file| require file }
require File.expand_path('../worker_errors.rb', __FILE__)

class ResultsCalculator
  include Sidekiq::Worker
   
  def perform(game_id)
    key = "game:#{game_id}"
    game = Game.where('id = ?', game_id).first
    return if game.nil?

    user_events = game.event_log
    return if user_events.nil? || user_events.empty?

    analysis_results = analyze_results(game, user_events)
    if analysis_results
      game.status = persist_results(game, analysis_results)
    else
      game.status = :incomplete_results
    end        

    unless game.save
      logger.error("Game #{game_id} cannot be saved post result calculation attempt.")
    end
  end

  def analyze_results(game, user_events)
    analysis_results = nil
    begin
      analyze_dispatcher = TidepoolAnalyze::AnalyzeDispatcher.new
      analysis_results = analyze_dispatcher.analyze(user_events, game.definition.recipe_names)
    rescue Exception => e
      logger.error("Game #{game.id} cannot analyze calculation. #{e.message}")
      game.last_error = e.message
    end
    analysis_results
  end

  def persist_results(game, analysis_results)
    status = :results_ready
    if game.definition 
      if game.definition.persist_as_results
        game.definition.persist_as_results.each do |result_name|
          klass_name = "Persist#{result_name.to_s.camelize}"
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
        logger.warn("No persist_as_results specified for game #{game.id}.")
      end
    else
      logger.error("Game #{game.id} definition is not defined or missing persist_as_results info.")
      status = :incomplete_results 
      game.last_error = "Game #{game.id} definition is not defined or missing persist_as_results info."
    end
    status  
  end
end
