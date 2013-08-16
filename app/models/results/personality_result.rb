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

class PersonalityResult < Result
  # store_accessor :score, :name
  # store_accessor :score, :one_liner
  # store_accessor :score, :logo_url
  store_accessor :score, :profile_description_id  

  def active_model_serializer
    PersonalityResultSerializer
  end

  def self.create_from_analysis(game, profile_description, version, existing_result = nil)
    return nil unless game && game.user_id
    return nil if profile_description.nil?

    result = existing_result
    result = game.results.build(:type => 'PersonalityResult') if result.nil?

    # result.name = profile_description.name
    # result.one_liner = profile_description.one_liner
    # result.logo_url = profile_description.logo_url
    result.profile_description_id = profile_description.id # This is an HStore accessor so needs to use id

    result.calculations = {}
    result.analysis_version = version
    result.record_times(game)
    result.save ? result : nil
  end
end
