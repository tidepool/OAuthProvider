require 'spec_helper'

describe ActivityAggregateResult do
  let(:user) { create(:user) }
  let(:activity) { create(:activity, user: user)}
  let(:activity_steps) { create_list(:activity_steps, 9, user: user)}

  it 'creates an activity aggretage result from an activity' do 
    activity
    result = ActivityAggregateResult.create_from_latest(activity, user.id, Date.current)
    result.should_not be_nil
    result.scores['weekly'][Date.current.wday].should == {
                   "most_steps" => 2000,
                  "least_steps" => 2000,
                  "total_steps" => 2000,
                "average_steps" => 2000,
                  "data_points" => 1
              }
  end

  it 'creates an activity aggregate when there are existing recorded activities' do 
    result = ActivityAggregateResult.create_from_latest(activity_steps[2], user.id, Date.current - 7.days)
    result = ActivityAggregateResult.create_from_latest(activity, user.id, Date.current)
    result.should_not be_nil
    result.scores['weekly'][Date.current.wday].should == {
               "most_steps" => 8000,
              "least_steps" => 2000,
              "total_steps" => 10000,
            "average_steps" => 5000,
              "data_points" => 2
        }    

    result = ActivityAggregateResult.where(user_id: user.id).first
    result.scores['weekly'][Date.current.wday].should == {
               "most_steps" => 8000,
              "least_steps" => 2000,
              "total_steps" => 10000,
            "average_steps" => 5000,
              "data_points" => 2
        }    
  end
end