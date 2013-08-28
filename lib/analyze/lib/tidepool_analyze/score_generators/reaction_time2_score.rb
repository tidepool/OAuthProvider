module TidepoolAnalyze
  module ScoreGenerator
    class ReactionTime2Score
      def calculate_score(input_data)
        return {} if input_data.class.to_s != 'Array' || input_data.length == 0

        output = {}
        input_data.each do | data |
          if data[:average_time] 
            speed_score = data[:score]
            if speed_score
              speed_score = (speed_score / 10).to_i
            end
            # Snoozer game results
            output = output.merge({
              average_time: data[:average_time],
              average_time_simple: data[:average_time_simple],
              average_time_complex: data[:average_time_complex],
              fastest_time: data[:fastest_time],
              slowest_time: data[:slowest_time],
              speed_score: speed_score,
              stage_data: data[:stage_data]                
            })
          else
            # Survey results
            output[:activity_level] = data[:activity] if data[:activity]
            output[:sleep_level] = data[:sleep] if data[:sleep]  
          end
        end
        output.merge({ version: '2.0' })
      end

    end
  end
end
