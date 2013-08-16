module TidepoolAnalyze
  module ScoreGenerator
    class ReactionTime2Score
      def calculate_score(input_data)
        return {} if input_data.class.to_s != 'Array' || input_data.length == 0

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

        output = {}
        input_data.each do | data |
          if data[:average_time] 
            simple_time_key = simple_time_mapping(data[:average_time_simple])
            complex_time_key = complex_time_mapping(data[:average_time_complex])

            if simple_time_key && complex_time_key
              lookup = "#{simple_time_key}-#{complex_time_key}"
              output = {
                speed_archetype: mapping[lookup],
                average_time: data[:average_time],
                average_time_simple: data[:average_time_simple],
                average_time_complex: data[:average_time_complex],
                fastest_time: data[:fastest_time],
                slowest_time: data[:slowest_time]                
              }
            end
          end
        end
        output.merge({ version: '2.0' })
      end

      def simple_time_mapping(average_time)
        case average_time
        when 0..300 then "fast"
        when 300..600 then "medium"
        when 600..150000 then "slow"
        else nil
        end
      end

      def complex_time_mapping(average_time)
        case average_time
        when 0..300 then "fast"
        when 300..600 then "medium"
        when 600..150000 then "slow"
        else nil
        end
      end
    end
  end
end
