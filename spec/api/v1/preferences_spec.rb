require 'spec_helper'

describe 'Preferences API' do 
  include AppConnections

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:user1) { create(:user) }
  let(:training_preference) { create(:preference, user: user1, type: 'TrainingPreference')}
  let(:user2) { create(:user) }

  it 'gets the description of a preference' do 
    token = get_conn(user1)
    response = token.get("#{@endpoint}/preferences/training-preference/description.json")
    response.status.should == 200
    reco_result = JSON.parse(response.body, symbolize_names: true)
    reco_result.should_not be_nil
  end

  it 'receives the preferences of a user' do 
    training_preference
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/preferences.json?type=TrainingPreference")
    response.status.should == 200
    reco_result = JSON.parse(response.body, symbolize_names: true)
    reco_result.should_not be_nil
    reco_result[:user_id].should == user1.id
    reco_result[:data].should == {
      :daily_emotion => "true",
      :learn_emotion => "false"
    }
    reco_result[:description][0].should == {
             :name => "more_in_less_time",
      :description => "Accomplish more in less time",
             :type => "checkbox",
         :category => "productivity"
    }
  end

  it 'creates a new preferences of a given type for user' do
    preference_params = {
      type: 'TrainingPreference',
      data: {
        :daily_emotion => "false",
        :learn_emotion => "true"
      }
    }
    preferences = user2.preferences
    preferences.should be_empty
    token = get_conn(user2)

    response = token.post("#{@endpoint}/users/-/preferences.json", {body: {preference: preference_params}})
    response.status.should == 200
    reco_result = JSON.parse(response.body, symbolize_names: true)
    reco_result.should_not be_nil


    preferences = user2.preferences
    preferences.should_not be_nil
    preferences[0].type.should == 'TrainingPreference'
    preferences[0].data.should == {
      "daily_emotion" => "false",
      "learn_emotion" => "true"
    }
  end

  it 'updates the preferences of a given type for user' do 
    training_preference
    preferences = user1.preferences
    preferences.should_not be_empty
    preferences[0].data.should == {
      "daily_emotion" => "true",
      "learn_emotion" => "false"
    }

    preference_params = {
      type: 'TrainingPreference',
      data: {
        :daily_emotion => "false"
      }
    }
    token = get_conn(user1)
    response = token.put("#{@endpoint}/users/-/preferences.json", {body: {preference: preference_params}})
    response.status.should == 200
    reco_result = JSON.parse(response.body, symbolize_names: true)
    reco_result.should_not be_nil
    user = User.find(user1.id)
    preferences = user.preferences
    preferences.should_not be_nil
    preferences[0].type.should == 'TrainingPreference'
    preferences[0].data.should == {
      "daily_emotion" => "false",
      "learn_emotion" => "false"
    }

  end

end