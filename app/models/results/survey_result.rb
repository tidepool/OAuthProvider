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

class SurveyResult < Result
  def self.create_from_analysis(game, analysis_results, existing_result = nil)
    return nil unless game && game.user_id
    return nil unless analysis_results && analysis_results[:survey] && analysis_results[:survey][:score]

    # There is only one result instance if this type per game
    result = existing_result
    result = game.results.build(:type => 'SurveyResult') if result.nil?

    result.user_id = game.user_id
    survey_score = analysis_results[:survey][:score]
    survey_results = {}
    survey_score.each do | topic, value |
      if topic.to_sym != :version
        if value.class == Hash && value[:answer]
          survey_results[topic] = value[:answer]
        else
          survey_results[topic] = value
        end
      end
    end
    result.score = survey_results
    result.calculations = survey_score 
    result.analysis_version = survey_score[:version]
    result.record_times(game, analysis_results[:survey][:timezone_offset])
    result.save ? result : nil
  end
end
