class MigrateToSchemaV2Seed
  def create_seed
    # Results deprecated columns:
    # event_log, aggregate_results, intermediate_results
    # Results new columns:
    # user_id, time_played, time_calculated, result_type, analysis_version, score, calculations
    puts 'Creating the migration'
    count = 0
    results = Result.all do |result|
      if result.analysis_version.nil?
        # Skip the already generated result
        game = result.game
        user = game.user

        game.event_log = result.event_log
        game.save

        result_types = [:Big5Result, :Holland6Result, :PersonalityResult]
        result_types.each do |result_type|
          new_result = game.results.build 
          new_result.user = user
          new_result.type = result_type 
          new_result.time_played = game.date_taken
          new_result.time_calculated = game.date_taken + 60 # Add an arbitrary 60 sec
          new_result.analysis_version = '1.0'
          case result_type
          when :Big5Result
            new_result.score = {
              dimension: personality.big5_dimension,
              low_dimension: personality.big5_low,
              high_dimension: personality.big5_high,
              adjust_by: 0
            }    
            new_result.calculations = {
              dimension_values: personality.big5_score,
              final_results: result.aggregate_results
            }
          when :Holland6Result
            new_result.score = {
              dimension: personality.holland6_dimension,
              adjust_by: 0
            }    
            new_result.calculations = {
              dimension_values: personality.holland6_score,
              final_results: result.aggregate_results
            }
          when :PersonalityResult
            profile_description = personality.profile_description
            new_result.score = {
              name: profile_description.name,
              one_liner: profile_description.one_liner,
              logo_url: profile_description.logo_url,
              profile_description_id: profile_description.id          
            }    
            new_result.calculations = {}
          end
          new_result.save
        end
        count += 1
        result.analysis_version = '1.0'
        result.save
      end
    end
    puts "Results migrated: #{count}\n"
    puts "Total results: #{Result.all.length}"
  end
end