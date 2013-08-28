class PersistSpeedArchetype 
  def persist(game, analysis_results)
    unless analysis_results && analysis_results[:reaction_time2] && analysis_results[:reaction_time2][:score]
      raise Workers::PersistenceError, "Analysis does not contain ReactionTime2 scores."
    end

    reaction_time2_score = analysis_results[:reaction_time2][:score]
    return unless score_valid(reaction_time2_score)

    aggregate_result = update_aggregate_result(game, analysis_results)
    desc = calculate_speed_archetype(aggregate_result, reaction_time2_score)

    # There is only one result instance if this type per game
    existing_result = Result.find_for_type(game, 'SpeedArchetypeResult')
    version = reaction_time2_score[:version] # We pick one of big5 vs. holland6 for the version here
    result = SpeedArchetypeResult.create_from_analysis(game, analysis_results, desc, version, existing_result)

    raise Workers::PersistenceError, 'SpeedArchetype result for game #{game.id} can not be persisted.' if result.nil?
  end

  def update_aggregate_result(game, analysis_results)
    existing_result = AggregateResult.find_for_type(game.user_id, 'SpeedAggregateResult')
    aggregate_result = SpeedAggregateResult.create_from_analysis(game, analysis_results, existing_result)
    
    raise Workers::PersistenceError, "Cannot create the SpeedAggregateResult." if aggregate_result.nil?

    aggregate_result
  end

  def score_valid(current_score)
    if current_score[:average_time_simple] == 0 || current_score[:average_time_complex] == 0
      false
    else
      true
    end
  end

  def calculate_speed_archetype(aggregate_result, current_score)
    mapping = {
      "fast-fast" => "falcon",
      "fast-medium" => "cheetah",
      "fast-slow" => "antelope", 
      "medium-fast" => "cat",
      "medium-medium" => "wolf",
      "medium-slow" => "dog",
      "slow-fast" => "crow",
      "slow-medium" => "gorilla",
      "slow-slow" => "dolphin"
    }
    scores = aggregate_result["scores"]
    total_simple_results = scores["simple"]["total_results"]
    total_complex_results = scores["complex"]["total_results"]

    if total_simple_results < 3
      speed_archetype = "progress#{total_simple_results}"    
    else
      simple_map = time_mapping(current_score[:average_time_simple], scores["simple"]["mean"], scores["simple"]["sd"])      
      complex_map = time_mapping(current_score[:average_time_complex], scores["complex"]["mean"], scores["complex"]["sd"])
      speed_archetype = mapping["#{simple_map}-#{complex_map}"]
    end
    desc = SpeedArchetypeDescription.where(speed_archetype: speed_archetype).first
  end

  def time_mapping(average_time, mean, sd)
    zscore = zscore(average_time, simple, sd)

    output = "medium"
    if zscore < -1
      output = "fast"
    elsif zscore > 1
      output = "slow"
    end
    output
  end

  def zscore(value, mean, sd)
    return 0.0 if sd == 0
    (value - mean) / sd
  end

end