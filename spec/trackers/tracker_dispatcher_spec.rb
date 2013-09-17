require 'spec_helper'

describe TrackerDispatcher do
  let(:user) { create(:user) }
  let(:connection) { create(:fitbit, user: user)}

  before :each do 
    Fitgem::Client.any_instance.stub(:activities_on_date).and_return({
      "summary" => {
        "steps"=>9663,
        "veryActiveMinutes"=>30
        }
      })
    Fitgem::Client.any_instance.stub(:sleep_on_date).and_return({
      "summary" => {
        "totalMinutesAsleep"=>360,
        "totalTimeInBed"=>400
        }
      })
    Fitgem::Client.any_instance.stub(:foods_on_date).and_return({
      "summary" => {
        "calories"=>2300,
        "water"=>5
        }
      })
    Fitgem::Client.any_instance.stub(:body_measurements_on_date).and_return({
      "body" => {
        "bmi"=>25,
        "weight"=>150
        }
      })
  end

  it 'synchronizes the tracker given the connection' do
    user
    connection
    tracker_dispatcher = TrackerDispatcher.new
    tracker_dispatcher.perform(connection.id)
    updated_connection = Authentication.find(connection.id)

    updated_connection.sync_status.should == "synchronized"

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
end
