class ReactionTimeGenerator < BaseGenerator
  def generate(stage_no, stage_template)
    result = {}
    result["friendly_name"] = stage_template["friendly_name"]
    result["instructions"] = stage_template["instructions"]
    result["view_name"] = stage_template["view_name"]
    result["sequence_type"] = stage_template["sequence_type"]

    colors = stage_template["colors"]
    number_of_reds = stage_template["number_of_reds"].to_i
    interval_floor = stage_template["interval_floor"].to_i
    interval_ceil = stage_template["interval_ceil"].to_i
    limit_to = stage_template["limit_to"].to_i
    # limit_to = 15

    # minimum count required
    if number_of_reds == 3
      min_count_simple = 6
      min_count_complex =  9
    elsif number_of_reds == 4
      min_count_simple = 7
      min_count_complex = 11
    elsif number_of_reds == 8
      min_count_simple = 16
      min_count_complex = 21
    end

    max = colors.length - 1
    min = 0
    count = 0

    sequence = []
    exit = false
    prior_color = ''
    forward_color = ''
    number_circles = 0
    yellow_count = 0
    red_count = 0

    min_abs = 1
    min_start = 0
    number_circles = rand(min_count_simple..(limit_to-1))
    # for complex slightly different starting values
    if result["sequence_type"] == "complex"
      number_circles = rand(min_count_complex..(limit_to-2))
      min_abs = 2
      min_start = 1
    end

    i = 1
    interval_for_targets = ( number_circles / number_of_reds )
    if result["sequence_type"] == "simple"
      interval_for_targets += 1
    end
    # puts interval_for_targets
    if interval_for_targets < 3
      interval_for_targets += 1
    end
    new_id = cir_sub_id = min_start

    while i <= number_of_reds
      pass = 0
      while pass != 1
        pass = 0
        target_red = rand( min_abs..interval_for_targets )
        cir_sub_id = new_id + target_red

        if i == 1
          new_id = cir_sub_id
          pass = 1
        else
          if ( cir_sub_id - new_id ).abs > min_abs
            new_id = cir_sub_id
            if new_id > number_circles
              # print number_circles, " newmax ", new_id, "\n"
              number_circles = new_id
            end

            if i == number_of_reds
              # puts new_id, number_circles, "\n"
              if number_circles > new_id
                new_id = number_circles
              else
                number_circles = new_id + min_start
              end
            end
            pass = 1
          end
        end
      end
      i += 1

      time_interval = (rand() * (interval_ceil - interval_floor + 1) + interval_floor).to_i
      sequence[new_id] = { color: 'red', interval: time_interval }
      # if complex second to last has to be yellow
      if result["sequence_type"] == "complex"
        time_interval = (rand() * (interval_ceil - interval_floor + 1) + interval_floor).to_i
        sequence[new_id - 1] = { color: 'yellow', interval: time_interval }
      end
    end

    # puts sequence

    while (not exit)
      outcome = (rand() * (max - min + 1) + min).to_i
      color = colors[outcome]

      # set forward color
      if sequence[count + 1].nil?
        forward_color = ''
      else
        forward_color = sequence[count + 1][:color]
      end

      if result["sequence_type"] == "simple" and color == 'red'
        # no more reds
      elsif result["sequence_type"] == "complex" and prior_color == 'yellow' and color == 'red'
        # no more yellow - red combos allowed
      #elsif yellow_count >= 6 or red_count >= 6
        # too many yellows or reds
      else
        #require consecutive circles to be different colors
        if prior_color != color and color != forward_color
          if sequence[count].nil?
            time_interval = (rand() * (interval_ceil - interval_floor + 1) + interval_floor).to_i
            sequence[count] = { color: color, interval: time_interval }
          end
          prior_color = sequence[count][:color]
          count += 1
        end
        yellow_count += 1 if color == 'yellow'
        red_count += 1 if color == 'red'
      end
      exit = true if count == number_circles
    end

    result["sequence"] = sequence
    result
  end
end