class SpeedAggregateResult < AggregateResult

  def active_model_serializer
    SpeedAggregateResultSerializer
  end

  def self.create_from_analysis(game, analysis_results, existing_result = nil)
    return nil unless game && game.user_id
    return nil unless analysis_results && analysis_results[:reaction_time2] && analysis_results[:reaction_time2][:score]

    user = User.where(id: game.user_id).first
    return nil if user.nil?

    result = existing_result
    if result.nil?
      result = user.aggregate_results.build(:type => 'SpeedAggregateResult') 
      result.initialize_scores
    end

    score = analysis_results[:reaction_time2][:score]
    new_simple = result.update_mean_and_sd("simple", score[:average_time_simple])
    new_complex = result.update_mean_and_sd("complex", score[:average_time_complex])

    hour = Time.zone.now.hour
    circadian = result.scores["circadian"]
    circadian[hour.to_s] = result.update_circadian(score, hour)

    result.scores = {
      "simple" => new_simple,
      "complex" => new_complex,
      "circadian" => circadian
    }
    result.save ? result : nil
  end

  def initialize_scores
    circadian = {}
    (0...24).each do |hour|
      circadian[hour.to_s] = {
        "speed_score" => 0,
        "fastest_time" => 100000,
        "slowest_time" => 0,
        "average_time_simple" => 100000,
        "average_time_complex" => 100000,
        "times_played" => 0        
      }
    end
    self.scores = {
      "simple" => {
        "sums" => 0.0,
        "total_results" => 0,
        "mean" => 0.0,
        "sd" => 0.0
      },
      "complex" => {
        "sums" => 0.0,
        "total_results" => 0,
        "mean" => 0.0,
        "sd" => 0.0
      },
      "circadian" => circadian
    }
  end

  def update_circadian(score, hour)
    circadian = self.scores["circadian"][hour.to_s]

    speed_score = circadian["speed_score"]
    speed_score = score[:speed_score] if score[:speed_score] > circadian["speed_score"] 
      
    fastest_time = circadian["fastest_time"]
    fastest_time = score[:fastest_time] if score[:fastest_time] < circadian["fastest_time"]

    slowest_time = circadian["slowest_time"]
    slowest_time = score[:slowest_time] if score[:slowest_time] > circadian["slowest_time"]

    average_time_simple = circadian["average_time_simple"]
    average_time_simple = score[:average_time_simple] if score[:average_time_simple] < circadian["average_time_simple"]

    average_time_complex = circadian["average_time_complex"]
    average_time_complex = score[:average_time_complex] if score[:average_time_complex] < circadian["average_time_complex"]

    times_played = circadian["times_played"]
    times_played += 1 

    {
      "speed_score" => speed_score,
      "fastest_time" => fastest_time,
      "slowest_time" => slowest_time,
      "average_time_simple" => average_time_simple,
      "average_time_complex" => average_time_complex,
      "times_played" => times_played
    }
  end

  # prev_mean = m;
  #  n = n + 1;
  #  m = m + (x-m)/n;
  #  S = S + (x-m)*(x-prev_mean);
  # std = sqrt(S/n)
  # http://dsp.stackexchange.com/questions/811/determining-the-mean-and-standard-deviation-in-real-time

  def update_mean_and_sd(score_type, new_score)
    prev_mean = self.scores[score_type]["mean"]
    total_results = self.scores[score_type]["total_results"] + 1

    mean = prev_mean + (new_score - prev_mean) / total_results
    sums = self.scores[score_type]["sums"] + (new_score - mean) * (new_score - prev_mean)
    sd = Math.sqrt(sums/total_results)

    # sum_1 = self.scores[:sum_1] + new_score
    # sum_2 = self.scores[:sum_2] + new_score ** 2
    # total_results = self.scores[:total_results] + 1

    # mean = sum_1 / total_results
    # sd = Math.sqrt(total_results * sum_2 - sum_1 ** 2) / total_results

    {
      "sums" => sums, 
      "total_results" => total_results,
      "mean" => mean,
      "sd" => sd
    }
  end

end