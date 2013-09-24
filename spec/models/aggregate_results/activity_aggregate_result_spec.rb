require 'spec_helper'

describe ActivityAggregateResult do
  let(:user) { create(:user) }
  let(:activity) { create(:activity, user: user) }

  it 'creates an activity aggregate result from an activity' do 
    activity
    today = Date.current
    result = ActivityAggregateResult.create_from_latest(activity, user.id, today)
    result.should_not be_nil
    result.scores['weekly'][today.wday].should == {
                   "most_steps" => 2000,
                  "total" => 2000,
                "average" => 2000,
                  "data_points" => 1
              }
    result.scores['trend'].should == 0.0 
    result.scores['last_value'].should == activity.steps
    result.scores['last_updated'].should == today.to_s
  end

  describe 'Multiple Activities' do 
    let(:activity1) { create(:activity, user: user) }
    let(:activity2) { create(:activity, user: user) }
    let(:activity3) { create(:activity, user: user) }
    let(:activity4) { create(:activity, user: user) }

    before :each do 
      activity1.data = { "steps" => "2000" }
      activity2.data = { "steps" => "3000" }
      activity3.data = { "steps" => "2500" }
      activity4.data = { "steps" => "5000" }

      activity1.save!
      activity2.save!
      activity3.save!
      activity4.save!
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
                  "total" => 5000,
                "average" => 2500,
            "data_points" => 2
          }    

      result = ActivityAggregateResult.where(user_id: user.id).first
      result.scores['weekly'][today.wday].should == {
             "most_steps" => 3000,
                  "total" => 5000,
                "average" => 2500,
            "data_points" => 2
          }  
    end

    it 'records the trend and most steps' do 
      today = Date.current
      result = ActivityAggregateResult.where(user_id: user.id).first
      result.should be_nil

      result1 = ActivityAggregateResult.create_from_latest(activity1, user.id, today - 7.days)
      result2 = ActivityAggregateResult.create_from_latest(activity2, user.id, today)
      average = (activity2.steps.to_f + activity1.steps.to_f) / 2
      result2.scores['trend'].should == (activity2.steps.to_f - average.to_f) / average.to_f
      result2.scores['last_value'].should == activity2.steps
      result2.scores['last_updated'].should == today.to_s
    end

    it 'does not update the trend if the activity is already updated for that day' do 
      today = Time.zone.parse("30 Sep 2013 18:00:00 PDT -07:00")
      result = ActivityAggregateResult.where(user_id: user.id).first
      result.should be_nil

      # A week ago's result
      result1 = ActivityAggregateResult.create_from_latest(activity1, user.id, today - 7.days)

      # Result coming in earlier in the day on the same weekday
      result2 = ActivityAggregateResult.create_from_latest(activity3, user.id, today - 3.hours)
      result2.scores['last_value'].should == activity3.steps
      result2.scores['weekly'][today.wday]['total'].should == activity1.steps + activity3.steps
      result2.scores['weekly'][today.wday]['data_points'].should == 2

      # Result coming in later in the day
      result3 = ActivityAggregateResult.create_from_latest(activity4, user.id, today - 1.hours)
      average = (activity4.steps.to_f + activity1.steps.to_f) / 2
      result3.scores['trend'].should == (activity4.steps.to_f - average.to_f) / average.to_f
      result3.scores['last_value'].should == activity4.steps
      result3.scores['weekly'][today.wday]['total'].should == activity1.steps + activity4.steps
      result3.scores['weekly'][today.wday]['data_points'].should == 2
      result3.scores['last_updated'].should == (today - 1.hours).to_s
    end
  end
end