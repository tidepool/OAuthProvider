require 'spec_helper'

describe FitbitTracker do
  let(:user) { create(:user) }
  let(:user1) { create(:user) }
  let(:connection) { create(:fitbit, user: user)}
  let(:fitbit_earlier) { create(:fitbit_earlier, user: user1)}
  before(:all) do 
  end

  it 'correctly calculates days to retrieve info' do 
    user
    tracker = FitbitTracker.new(connection, nil)
    days = tracker.days_to_retrieve(:activities)
    days.should == 3
    days = tracker.days_to_retrieve(:sleeps)
    days.should == 1  # Always sync the current day
    days = tracker.days_to_retrieve(:foods)
    days.should == 6
    days = tracker.days_to_retrieve(:measurements)
    days.should == 3
  end

  it 'calls the APIs for the correct number of days back' do
    user
    tracker = FitbitTracker.new(connection, nil)
    sync_list = [:activities]
    Fitgem::Client.any_instance.stub(:activities_on_date).and_return({
      "summary" => {
        "steps"=>9663,
        "veryActiveMinutes"=>30
        }
      })
    tracker.synchronize(sync_list)

    activities = Activity.where('user_id = ? and provider = ?', user.id, 'fitbit').order(:date_recorded)
    activities.length.should == 3
    activities[2].date_recorded.should == Date.current
  end

  it 'sets the last synchronized date correctly if ' do 
    user1
    tracker = FitbitTracker.new(fitbit_earlier, nil)
    sync_list = [:activities, :sleeps]
    Fitgem::Client.any_instance.stub(:activities_on_date).and_return({
      "summary" => {
        "steps"=>9663,
        "veryActiveMinutes"=>30
        }
      })
    Fitgem::Client.any_instance.stub(:sleep_on_date) do |date|
      day = Time.parse(date).yday
      today = Time.zone.now.yday
      if day == today - 1
        raise Exception.new
      end
      { "summary" => {"totalMinutesAsleep"=>375, "totalSleepRecords"=>1, "totalTimeInBed"=>430} }
    end
    activity_days = tracker.days_to_retrieve(:activities)
    sleep_days = tracker.days_to_retrieve(:sleeps)

    expect{ tracker.synchronize(sync_list)}.to raise_error(Exception)
    connection = Authentication.where(user_id: user1.id, provider: 'fitbit').first
    connection.last_synchronized.should_not be_nil   
    Time.parse(connection.last_synchronized['sleeps']).yday.should == Time.zone.now.yday - 2
  end

  describe 'Activity storage' do
    let(:activity) { create(:activity, user: user) }
    before(:each) do 
      Fitgem::Client.any_instance.stub(:activities_on_date).and_return({
        "activities" =>[],
        "goals" => {
          "activeScore"=>1000,
          "caloriesOut"=>2184,
          "distance"=>5,
          "floors"=>10,
          "steps"=>10000
          },
        "summary" => {
          "activeScore" => 545,
          "activityCalories" => 865,
          "caloriesBMR" => 1317,
          "caloriesOut" => 1978,
          "distances" => [
            {"activity"=>"total", "distance"=>4.24},
            {"activity"=>"tracker", "distance"=>4.24},
            {"activity"=>"loggedActivities", "distance"=>0},
            {"activity"=>"veryActive", "distance"=>1.33},
            {"activity"=>"moderatelyActive", "distance"=>2.71},
            {"activity"=>"lightlyActive", "distance"=>0.2},
            {"activity"=>"sedentaryActive", "distance"=>0}
            ],
          "elevation"=>130,
          "fairlyActiveMinutes"=>70,
          "floors"=>13,
          "lightlyActiveMinutes"=>67,
          "marginalCalories"=>611,
          "sedentaryMinutes"=>909,
          "steps"=>9663,
          "veryActiveMinutes"=>30
          }
        })
    end

    it 'persists activity to the database when the todays activity does not exist' do 
      client = Fitgem::Client.new({
        consumer_key: ENV['FITBIT_KEY'],
        consumer_secret: ENV['FITBIT_SECRET']})

      user
      tracker = FitbitTracker.new(connection, client)
      new_activity = tracker.persist_activities(Date.current)

      new_activity.should_not be_nil
      new_activity.floors.should == 13
      new_activity.steps.should == 9663
      new_activity.distance.should == 4.24
      new_activity.very_active_minutes.should == 30

      new_activity.floors_goal.should == 10
      new_activity.steps_goal.should == 10000
      new_activity.distance_goal.should == 5.0
      new_activity.calories_goal.should == 2184

      result = ActivityAggregateResult.where(user_id: user.id).first
      result.should_not be_nil
      result.scores['weekly'][Date.current.wday].should == {
                           "most_steps" => 9663,
                          "least_steps" => 9663,
                          "total" => 9663,
                        "average" => 9663,
                          "data_points" => 1
      }
    end

    it 'persists activity to the database when the todays activity already exists' do 
      client = Fitgem::Client.new({
        consumer_key: ENV['FITBIT_KEY'],
        consumer_secret: ENV['FITBIT_SECRET']})

      activity
      user
      tracker = FitbitTracker.new(connection, client)
      new_activity = tracker.persist_activities(Date.current)
      new_activity.should_not be_nil

      new_activity.id.should == activity.id
      new_activity.user.should == user
      new_activity.date_recorded.should == activity.date_recorded
      new_activity.provider.should == 'fitbit'
      new_activity.floors.should == 13
      new_activity.steps.should == 9663
      new_activity.distance.should == 4.24
      new_activity.very_active_minutes.should == 30

      new_activity.floors_goal.should == 10
      new_activity.steps_goal.should == 10000
      new_activity.distance_goal.should == 5.0
      new_activity.calories_goal.should == 2184
    end
  end

  describe 'Sleep storage' do 
    before(:each) do 
      Fitgem::Client.any_instance.stub(:sleep_on_date).and_return({
        "sleep"=>
           [{"awakeningsCount"=>14,
             "duration"=>25800000,
             "efficiency"=>90,
             "isMainSleep"=>true,
             "logId"=>51345943,
             "minuteData"=>
              [{"dateTime"=>"23:54:00", "value"=>"3"},
               {"dateTime"=>"23:55:00", "value"=>"3"},
               {"dateTime"=>"07:02:00", "value"=>"2"},
               {"dateTime"=>"07:03:00", "value"=>"2"}],
             "minutesAfterWakeup"=>6,
             "minutesAsleep"=>375,
             "minutesAwake"=>41,
             "minutesToFallAsleep"=>8,
             "startTime"=>"2013-08-14T23:54:00.000",
             "timeInBed"=>430}],
          "summary"=>
           {"totalMinutesAsleep"=>375, "totalSleepRecords"=>1, "totalTimeInBed"=>430}
        })
    end

    it 'persists the sleep info to database when the todays sleep does not exist' do 
      client = Fitgem::Client.new({
        consumer_key: ENV['FITBIT_KEY'],
        consumer_secret: ENV['FITBIT_SECRET']})

      user
      tracker = FitbitTracker.new(connection, client)
      new_sleep = tracker.persist_sleeps(Date.current)
      new_sleep.should_not be_nil
      new_sleep.total_minutes_in_bed.should == 430
      new_sleep.total_minutes_asleep.should == 375
      new_sleep.efficiency.should == 90
      new_sleep.minutes_to_fall_asleep.should == 8
      new_sleep.start_time.should == "2013-08-14T23:54:00.000"
      new_sleep.number_of_times_awake.should == 14
      new_sleep.minutes_awake.should == 41
      new_sleep.minutes_after_wake_up.should == 6

    end
  end
end