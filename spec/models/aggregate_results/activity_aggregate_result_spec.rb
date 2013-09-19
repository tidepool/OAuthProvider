require 'spec_helper'

describe ActivityAggregateResult do
  let(:user) { create(:user) }
  let(:activity) { create(:activity, user: user) }

  it 'creates an activity aggretage result from an activity' do 
    activity
    today = Date.current
    result = ActivityAggregateResult.create_from_latest(activity, user.id, today)
    result.should_not be_nil
    result.scores['weekly'][today.wday].should == {
                   "most_steps" => 2000,
                  "least_steps" => 2000,
                  "total" => 2000,
                "average" => 2000,
                  "data_points" => 1
              }
    result.scores['trend'].should == 999.99 # Our value to indicate no change
    result.scores['last_value'].should == activity.steps
    result.scores['last_updated'].should == today.to_s
  end

  describe 'Multiple Activities' do 
    let(:activity1) { create(:activity, user: user) }
    let(:activity2) { create(:activity, user: user) }

    before :each do 
      activity1.data = {
        "very_active_minutes" => "30",
        "floors" => "5",
        "steps" => "2000",
        "distance" => "4.24",
        "calories" => "1978"
      }
      activity2.data = {
        "very_active_minutes" => "30",
        "floors" => "5",
        "steps" => "3000",
        "distance" => "4.24",
        "calories" => "1978"
      }
      activity1.save!
      activity2.save!
    end

    it 'creates an activity aggregate when there are existing recorded activities' do 
      today = Date.current
      result = ActivityAggregateResult.where(user_id: user.id).first
      result.should be_nil

      result1 = ActivityAggregateResult.create_from_latest(activity1, user.id, today - 7.days)
      result2 = ActivityAggregateResult.create_from_latest(activity2, user.id, today)
      result2.should_not be_nil
      result2.scores['weekly'][today.wday].should == {
             "most_steps" => 3000,
            "least_steps" => 2000,
                  "total" => 5000,
                "average" => 2500,
            "data_points" => 2
          }    

      result = ActivityAggregateResult.where(user_id: user.id).first
      result.scores['weekly'][today.wday].should == {
             "most_steps" => 3000,
            "least_steps" => 2000,
                  "total" => 5000,
                "average" => 2500,
            "data_points" => 2
          }  
    end

    it 'records the trend and most steps' do 
      today = Date.current
      result = ActivityAggregateResult.where(user_id: user.id).first
      result.should be_nil

      result1 = ActivityAggregateResult.create_from_latest(activity1, user.id, today - 1.days)
      result2 = ActivityAggregateResult.create_from_latest(activity2, user.id, today)
      result2.scores['trend'].should == (activity2.steps.to_f - activity1.steps.to_f) / activity1.steps.to_f
      result2.scores['last_value'].should == activity2.steps
      result2.scores['last_updated'].should == today.to_s
    end
  end
end