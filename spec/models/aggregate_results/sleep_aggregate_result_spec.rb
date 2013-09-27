require 'spec_helper'

describe SleepAggregateResult do
  let(:user) { create(:user) }
  let(:sleep) { create(:sleep, user: user)}

  it 'creates a sleep aggretage result from sleep data' do 
    today = Date.current
    result = SleepAggregateResult.create_from_latest(sleep, user.id, today)
    result.should_not be_nil
    result.scores['weekly'][today.wday].should == {
               "most_minutes" => 365,
              "least_minutes" => 365,
              "total" => 365,
            "average" => 365,
                "data_points" => 1
        }

    result = SleepAggregateResult.where(user_id: user.id).first
    result.scores['weekly'][today.wday].should == {
               "most_minutes" => 365,
              "least_minutes" => 365,
              "total" => 365,
            "average" => 365,
                "data_points" => 1
        }
    result.scores['trend'].should == 0.0 
    result.scores['last_value'].should == sleep.total_minutes_asleep
    result.scores['last_updated'].should == today.to_s
  end

end