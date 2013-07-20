class FitbitTracker
  def initialize(user, connection, client = nil)
    @user = user
    @connection = connection
    @client = client
  end

  def synchronize(sync_list = nil)
    return if @connection.nil? || @connection.provider != 'fitbit'

    last_synchronized = @connection.last_synchronized
    last_synchronized = {} if last_synchronized.nil?

    @client = Fitgem::Client.new(client_config) if @client.nil?
    if @client
      sync_list = [:activities, :sleeps, :foods, :measurements] if sync_list.nil?

      sync_list.each do | item |
        number_of_days = days_to_retrieve(item)
        number_of_days.times do | day |
          date = Date.current - (number_of_days - day).days        
          method_name = "persist_#{item}".to_sym
          sync_item = self.method(method_name).call(date) if self.method(method_name)

          if sync_item
            sync_item.provider = 'fitbit'
            sync_item.user = @user
            sync_item.date_recorded = date
            sync_item.save!
          end
        end 
        last_synchronized[item.to_s] = Time.zone.now
      end
      @connection.last_synchronized = last_synchronized
      @connection.save!
    end
  end

  # {:consumer_key=>"4c4660694a7844d081bfaf93ef0d2330",
  #  :consumer_secret=>"b31bf5b8dcc748ea900b9c487d86973d",
  #  :token=>"c0bcc7078b68c845b84f97676ab21420",
  #  :secret=>"1b92f4dda6c1b995179de337a900a02a",
  #  :user_id=>"22NNBC"}
  def client_config
    {
      consumer_key: ENV['FITBIT_KEY'],
      consumer_secret: ENV['FITBIT_SECRET'],
      token: @connection.oauth_token,
      secret: @connection.oauth_secret,
      user_id: @connection.uid
    }
  end  

  def days_to_retrieve(type_of_data)
    number_of_days = 3 # If not synchronized ever then make it 3 days
    return number_of_days if @connection.last_synchronized.nil?

    last_synchronized = @connection.last_synchronized[type_of_data.to_s]
    if last_synchronized
      last_synchronized = Time.parse(last_synchronized)
      number_of_days = ((Time.zone.now - last_synchronized) / 1.day).ceil
    end
    number_of_days
  end

  # {"activities"=>[],
  #  "goals"=>
  #   {"activeScore"=>1000,
  #    "caloriesOut"=>2184,
  #    "distance"=>5,
  #    "floors"=>10,
  #    "steps"=>10000},
  #  "summary"=>
  #   {"activeScore"=>545,
  #    "activityCalories"=>865,
  #    "caloriesBMR"=>1317,
  #    "caloriesOut"=>1978,
  #    "distances"=>
  #     [{"activity"=>"total", "distance"=>4.24},
  #      {"activity"=>"tracker", "distance"=>4.24},
  #      {"activity"=>"loggedActivities", "distance"=>0},
  #      {"activity"=>"veryActive", "distance"=>1.33},
  #      {"activity"=>"moderatelyActive", "distance"=>2.71},
  #      {"activity"=>"lightlyActive", "distance"=>0.2},
  #      {"activity"=>"sedentaryActive", "distance"=>0}],
  #    "elevation"=>130,
  #    "fairlyActiveMinutes"=>70,
  #    "floors"=>13,
  #    "lightlyActiveMinutes"=>67,
  #    "marginalCalories"=>611,
  #    "sedentaryMinutes"=>909,
  #    "steps"=>9663,
  #    "veryActiveMinutes"=>30}
  # }
  def persist_activities(date)
    return if @client.nil?

    activity_hash = @client.activities_on_date(date.to_s)

    activity = Activity.where('date_recorded = ? and user_id = ? and provider = ?', date, @user.id, 'fitbit').first_or_initialize

    summary = activity_hash["summary"]
    if summary
      activity.very_active_minutes = summary["veryActiveMinutes"]
      activity.floors = summary["floors"]
      activity.steps = summary["steps"]
      distances = summary["distances"]
      if distances
        distances.each do | distance_hash |
          if distance_hash["activity"] == "total"
            activity.distance = distance_hash["distance"]
          end
        end
      end
      activity.calories = summary["caloriesOut"]
      activity.elevation = summary["elevation"]
    end

    goals = activity_hash["goals"]
    if goals      
      activity.floors_goal = goals["floors"]
      activity.steps_goal = goals["steps"]
      activity.distance_goal = goals["distance"]
      activity.calories_goal = goals["caloriesOut"]
    end

    daily_breakdown = activity_hash["activities"]
    if daily_breakdown
      activity.daily_breakdown = daily_breakdown
    end

    activity
  end

  # {"sleep"=>[],
  #   "summary"=>
  #    {"totalMinutesAsleep"=>0, "totalSleepRecords"=>0, "totalTimeInBed"=>0}}
  def persist_sleeps(date)
    return if @client.nil?

    sleep_hash = @client.sleep_on_date date.to_s

    sleep = Sleep.where('date_recorded = ? and user_id = ? and provider = ?', date, @user.id, 'fitbit').first_or_initialize

    summary = sleep_hash["summary"]
    if summary 
      sleep.total_minutes_asleep = summary["totalMinutesAsleep"]
      sleep.total_minutes_in_bed =  summary["totalTimeInBed"]
    end
    sleep
  end

  # {"foods"=>[],
  #   "goals"=>{"calories"=>1582},
  #   "summary"=>
  #    {"calories"=>0,
  #     "carbs"=>0,
  #     "fat"=>0,
  #     "fiber"=>0,
  #     "protein"=>0,
  #     "sodium"=>0,
  #     "water"=>0}}
  def persist_foods(date)
    return if @client.nil?

    food_hash = @client.foods_on_date date.to_s

    food = Food.where('date_recorded = ? and user_id = ? and provider = ?', date, @user.id, 'fitbit').first_or_initialize

    summary = food_hash["summary"]
    if summary 
      food.calories = summary["calories"]
      food.water =  summary["water"]
    end

    goals = food_hash["goals"]
    if goals
      food.calories_goal = goals["calories"]
    end

    food
  end

  # {"body"=>
  #    {"bicep"=>0,
  #     "bmi"=>0,
  #     "calf"=>0,
  #     "chest"=>0,
  #     "fat"=>0,
  #     "forearm"=>0,
  #     "hips"=>0,
  #     "neck"=>0,
  #     "thigh"=>0,
  #     "waist"=>0,
  #     "weight"=>0},
  #   "goals"=>{"weight"=>185.39}
  def persist_measurements(date)
    return if @client.nil?

    measurement_hash = @client.body_measurements_on_date date.to_s

    measurement = Measurement.where('date_recorded = ? and user_id = ? and provider = ?', date, @user.id, 'fitbit').first_or_initialize

    body = measurement_hash["body"]
    if body 
      measurement.weight = body["weight"]
      measurement.bmi =  body["bmi"]
    end

    goals = measurement_hash["goals"]
    if goals
      measurement.weight_goal = goals["weight"]
    end

    measurement
  end
end