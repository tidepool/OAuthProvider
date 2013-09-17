require 'spec_helper'

describe SleepAggregateResult do
  let(:user) { create(:user) }
  let(:sleep) { create(:sleep, user: user)}

  it 'creates a sleep aggretage result from sleep data' do 
    result = SleepAggregateResult.create_from_latest(sleep, user.id, Date.current)
    result.should_not be_nil
    result.scores['weekly'][Date.current.wday].should == {
               "most_minutes" => 365,
              "least_minutes" => 365,
              "total" => 365,
            "average" => 365,
                "data_points" => 1
        }

    result = SleepAggregateResult.where(user_id: user.id).first
    result.scores['weekly'][Date.current.wday].should == {
               "most_minutes" => 365,
              "least_minutes" => 365,
              "total" => 365,
            "average" => 365,
                "data_points" => 1
        }
  end

end