class Result < ActiveRecord::Base
  # serialize :event_log, JSON
  serialize :intermediate_results, JSON  # deprecated DONOT use
  serialize :aggregate_results, JSON # deprecated DONOT use

  serialize :calculations, JSON
  store_accessor :score, :version

  # belongs_to :profile_description
  belongs_to :game
  belongs_to :user

  def self.find_for_type(game, result_type)
    result = Result.where('game_id = ? and type = ?', game.id, result_type).first
  end  
end
