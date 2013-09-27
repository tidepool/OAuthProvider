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

class Holland6Result < Result
  store_accessor :score, :dimension
  store_accessor :score, :adjust_by

  def self.create_from_analysis(game, analysis_results, existing_result = nil)
    return nil unless game && game.user_id
    return nil unless analysis_results && analysis_results[:holland6] && analysis_results[:holland6][:score]

    # There is only one result instance if this type per game
    result = existing_result
    result = game.results.build(:type => 'Holland6Result') if result.nil?

    result.user_id = game.user_id
    score = analysis_results[:holland6][:score]
    result.dimension = score[:dimension]
    result.adjust_by = score[:adjust_by]
    result.calculations = {
      dimension_values: score[:dimension_values],
      final_results: analysis_results[:holland6][:final_results]
    }
    result.analysis_version = score[:version]
    result.record_times(game, analysis_results[:holland6][:timezone_offset])
    result.save ? result : nil
  end
end
