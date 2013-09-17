# == Schema Information
#
# Table name: results
#
#  id                   :integer          not null, primary key
#  game_id              :integer          not null
#  event_log            :text
#  intermediate_results :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  aggregate_results    :text
#  score                :hstore
#  calculations         :text
#  user_id              :integer
#  time_played          :datetime
#  time_calculated      :datetime
#  analysis_version     :string(255)
#  type                 :string(255)
#

class Result < ActiveRecord::Base
  include Paginate
  
  # serialize :event_log, JSON
  serialize :intermediate_results, JSON  # deprecated DONOT use
  serialize :aggregate_results, JSON # deprecated DONOT use

  serialize :calculations, JSON
  store_accessor :score, :version

  # belongs_to :profile_description
  belongs_to :game
  belongs_to :user

  def active_model_serializer
    ResultSerializer
  end

  def self.find_for_type(game, result_type)
    result = Result.where('game_id = ? and type = ?', game.id, result_type).first
  end  

  def record_times(game)
    self.time_played = game.date_taken
    self.time_calculated = Time.zone.now
  end

end
