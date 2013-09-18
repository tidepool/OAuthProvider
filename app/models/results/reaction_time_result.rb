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

class ReactionTimeResult < Result
  store_accessor :score, :fastest_time
  store_accessor :score, :slowest_time
  store_accessor :score, :average_time

  def self.create_from_analysis(game, analysis_results, existing_result = nil)
    return nil unless game && game.user_id
    return nil unless analysis_results && analysis_results[:reaction_time] && analysis_results[:reaction_time][:score]

    result = existing_result
    result = game.results.build(:type => 'ReactionTimeResult') if result.nil?

    result.user_id = game.user_id
    score = analysis_results[:reaction_time][:score]
    result.fastest_time = score[:fastest_time]
    result.slowest_time = score[:slowest_time]
    result.average_time = score[:average_time]
        
    result.calculations = {
      "final_results" => analysis_results[:reaction_time][:final_results]
    }
    result.analysis_version = score[:version]
    result.record_times(game, analysis_results[:reaction_time][:timezone_offset])
    result.save ? result : nil
  end
end
