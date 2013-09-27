class FitbitTracker
  include TimeZoneCalculations

  def self.batch_update_connections(updates)
    return if updates.nil? || updates.class != Array
    item_mapping = {
      "activities" => "activities", 
      "sleep" => "sleeps",
      "foods" => "foods",
      "body" => "measurements"
    }
    updates.each do |update|
      item_type = item_mapping[update["collectionType"]]
      if item_type.nil?
        Rails.logger("ProviderError: Incorrect item_type provided - #{update['collectionType']}")
        next
      end

      subscription_id = update["subscriptionId"]
      connection = Authentication.where(user_id: subscription_id.to_i).first
      if connection.nil?
        Rails.logger("ProviderError: Cannot find subscriber with user_id #{subscription_id}")
        next
      end
      last_sync_times = {}
      begin 
        tracker = FitbitTracker.new(connection)
        date_str = update["date"]
        time_synchronized = tracker.time_from_offset(Time.zone.parse(date_str), connection.timezone_offset)
        sync_item = tracker.synchronize_each(time_synchronized, item_type)
        last_sync_times[item_type.to_s] = time_synchronized.to_s if sync_item
      rescue Trackers::AuthenticationError => e
        connection.sync_status = :authentication_error
        connection.last_error = e.message
        Rails.logger.error("Provider Fitbit cannot authenticate - #{e.message}")
      rescue Exception => e
        connection.sync_status = :sync_error
        connection.last_error = e.message
        Rails.logger.error("Provider Fitbit cannot synchronize - #{e.message}")        
      ensure
        last_synchronized = connection.last_synchronized
        last_synchronized = {} if last_synchronized.nil?
        new_times = last_synchronized.merge(last_sync_times)
        connection.last_synchronized = new_times
        connection.last_accessed = Time.zone.now
        connection.save!
      end        
    end
  end

  def initialize(connection, client = nil)
    @user_id = connection.user_id if connection
    @connection = connection
    @client = client
    @client = Fitgem::Client.new(client_config) if @client.nil?
  end

  def logger
    Rails.logger
  end

  def synchronize(sync_list = nil)
    return if @connection.nil? || @connection.provider != 'fitbit'
    sync_list = [:activities, :sleeps, :foods, :measurements] if sync_list.nil?
    last_sync_times = {}
    logger.info("ProviderFitbit: start synchronize.")
    today = time_from_offset(Time.zone.now, @connection.timezone_offset)
    logger.info("ProviderFitbit: start synchronize for #{today.to_s}.")
    if @client
      sync_list.each do | item |
        number_of_days = days_to_retrieve(item)
        logger.info("ProviderFitbit: synchronizing #{item} for #{number_of_days} days.")
        number_of_days.times do | day |
          time_synchronized = today - (number_of_days - day - 1).days    
          sync_item = synchronize_each(time_synchronized, item) 
          last_sync_times[item.to_s] = time_synchronized.to_s if sync_item
        end 
      end
    end
  ensure
    last_synchronized = @connection.last_synchronized
    last_synchronized = {} if last_synchronized.nil?
    new_times = last_synchronized.merge(last_sync_times)
    @connection.last_synchronized = new_times
    @connection.save!
  end

  def synchronize_each(time_synchronized, item)
    last_sync_times = {}
    method_name = "persist_#{item}".to_sym

    date_synchronized = Date.parse(time_synchronized.to_s) # This is important, otherwise ActiveRecord converts using timezone
    sync_item = self.method(method_name).call(date_synchronized) if self.method(method_name)

    if sync_item
      sync_item.provider = 'fitbit'
      sync_item.user_id = @user_id
      sync_item.date_recorded = date_synchronized
      sync_item.save!
      logger.info("#{item} synchronized successfully for #{@user_id}.")
    end
    sync_item
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
      last_synchronized = time_from_offset(Time.parse(last_synchronized), @connection.timezone_offset)
      today = time_from_offset(Time.zone.now, @connection.timezone_offset)
      # We add +1 here, because we always need to synchronize the current day as the data
      # will be coming in. For days before the current day, the data will be frozen (i.e can take any
      # more steps yesterday) so we will synchronize it one last time.to get the full data for that day.
      number_of_days = today.yday - last_synchronized.yday + 1
    end
    number_of_days 
  end

  # "errors"=>
  #    [{"errorType"=>"oauth",
  #      "fieldName"=>"oauth_access_token",
  #      "message"=>
  #       "Invalid signature or token 'a29kGlKEW3YHCIH8JZM/WUVE6uw=' or token '4b8f3d3eae93411192c491939c07808e'"}]},
  def check_for_errors(result_hash)
    if result_hash.has_key?('errors')
      errors = result_hash["errors"]
      errors.each do |error|
        if error["errorType"] == "oauth"
          raise Trackers::AuthenticationError, error["message"]
        else
          raise Trackers::ConnectionError, error["message"]
        end
      end
    end
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
    check_for_errors(activity_hash)

    activity = Activity.where('date_recorded = ? and user_id = ? and provider = ?', date, @user_id, 'fitbit').first_or_initialize

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

    ActivityAggregateResult.create_from_latest(activity, @user_id, date)
    
    activity
  end

  # {"sleep"=>[],
  #   "summary"=>
  #    {"totalMinutesAsleep"=>0, "totalSleepRecords"=>0, "totalTimeInBed"=>0}}
  def persist_sleeps(date)
    return if @client.nil?

    sleep_hash = @client.sleep_on_date date.to_s
    check_for_errors(sleep_hash)

    sleep = Sleep.where('date_recorded = ? and user_id = ? and provider = ?', date, @user_id, 'fitbit').first_or_initialize

    summary = sleep_hash["summary"]
    if summary 
      sleep.total_minutes_asleep = summary["totalMinutesAsleep"]
      sleep.total_minutes_in_bed =  summary["totalTimeInBed"]
    end
    sleep_details = sleep_hash["sleep"]
    if sleep_details
      if sleep_details.class == Array
        sleep_details.each do |details|
          # Only record the main sleep for now
          if details["isMainSleep"] && details["isMainSleep"] == true
            sleep.efficiency = details["efficiency"]
            sleep.minutes_to_fall_asleep = details["minutesToFallAsleep"]
            sleep.start_time = details["startTime"]
            sleep.number_of_times_awake = details["awakeningsCount"]
            sleep.minutes_awake = details["minutesAwake"]
            sleep.minutes_after_wake_up = details["minutesAfterWakeup"]
          end
        end
      end 
    end

    SleepAggregateResult.create_from_latest(sleep, @user_id, date)
    
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
    check_for_errors(food_hash)

    food = Food.where('date_recorded = ? and user_id = ? and provider = ?', date, @user_id, 'fitbit').first_or_initialize

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
    check_for_errors(measurement_hash)

    measurement = Measurement.where('date_recorded = ? and user_id = ? and provider = ?', date, @user_id, 'fitbit').first_or_initialize

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