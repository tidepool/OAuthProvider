require 'spec_helper'

describe FitbitTracker do
  let(:user) { create(:user) }
  let(:connection) { create(:fitbit, user: user)}

  before(:all) do 
  end

  it 'correctly calculates days to retrieve info' do 
    tracker = FitbitTracker.new(user, connection, nil)
    days = tracker.days_to_retrieve(:activities)
    days.should == 3
    days = tracker.days_to_retrieve(:sleeps)
    days.should == 1
    days = tracker.days_to_retrieve(:foods)
    days.should == 6
    days = tracker.days_to_retrieve(:measurements)
    days.should == 3
  end

  it 'calls the APIs for the correct number of days back' do
    tracker = FitbitTracker.new(user, connection, nil)
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

      tracker = FitbitTracker.new(user, connection, client)
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
    end

    it 'persists activity to the database when the todays activity already exists' do 
      client = Fitgem::Client.new({
        consumer_key: ENV['FITBIT_KEY'],
        consumer_secret: ENV['FITBIT_SECRET']})

      activity
      tracker = FitbitTracker.new(user, connection, client)
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
end