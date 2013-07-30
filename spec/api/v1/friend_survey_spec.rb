require 'spec_helper'

describe 'Friend Surveys API' do 
  include AppConnections

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:guest) { create(:guest) }
  let(:game) { create(:game, user: guest) }
  let(:result) { create(:big5_result, user:guest, game: game) }

  it 'records a survey result' do 
    token = get_conn()
    survey_params = { 
      high_extraversion: 1,
      low_extraversion: 4, 
      high_openness: 3, 
      low_openness: 7,
      high_neuroticism: 2,
      low_neuroticism: 6,
      high_conscientiousness: 4,
      low_conscientiousness: 2,
      high_agreeableness: 1,
      low_agreeableness: 3
    }
    response = token.post("#{@endpoint}/games/#{game.id}/friend_survey.json", { friend_survey: survey_params } )
    result = JSON.parse(response.body, symbolize_names: true)
    result.should_not be_nil
    content = result[:data]
    content[:game_id].should == game.id

    friend_survey = FriendSurvey.find(content[:id])
    friend_survey.answers.should == {
           "high_extraversion" => "1",
            "low_extraversion" => "4",
               "high_openness" => "3",
                "low_openness" => "7",
            "high_neuroticism" => "2",
             "low_neuroticism" => "6",
      "high_conscientiousness" => "4",
       "low_conscientiousness" => "2",
          "high_agreeableness" => "1",
           "low_agreeableness" => "3"
    }
  end

  describe 'calculations' do 
    before :all do 
      @survey_params1 = { 
        high_extraversion: 1,
        low_extraversion: 4, 
        high_openness: 3, 
        low_openness: 7,
        high_neuroticism: 2,
        low_neuroticism: 6,
        high_conscientiousness: 4,
        low_conscientiousness: 2,
        high_agreeableness: 1,
        low_agreeableness: 3
      }
      @survey_params2 = { 
        high_extraversion: 2,
        low_extraversion: 5, 
        high_openness: 1, 
        low_openness: 5,
        high_neuroticism: 3,
        low_neuroticism: 6,
        high_conscientiousness: 4,
        low_conscientiousness: 1,
        high_agreeableness: 7,
        low_agreeableness: 3
      }
      @survey_params3 = { 
        high_extraversion: 2,
        low_extraversion: 6, 
        high_openness: 4, 
        low_openness: 5,
        high_neuroticism: 3,
        low_neuroticism: 7,
        high_conscientiousness: 6,
        low_conscientiousness: 1,
        high_agreeableness: 6,
        low_agreeableness: 2
      }
    end

    it 'calculates the survey results' do 
      result
      token = get_conn()
      response = token.post("#{@endpoint}/games/#{game.id}/friend_survey.json", { friend_survey: @survey_params1 } )
      response = token.post("#{@endpoint}/games/#{game.id}/friend_survey.json", { friend_survey: @survey_params2 } )
      response = token.post("#{@endpoint}/games/#{game.id}/friend_survey.json", { friend_survey: @survey_params3 } )

      response = token.get("#{@endpoint}/games/#{game.id}/friend_survey.json" )
      result = JSON.parse(response.body, symbolize_names: true)
      result.should_not be_nil
    end

    it 'returns an error if the survey is not ready' do 
      result
      token = get_conn()
      response = token.post("#{@endpoint}/games/#{game.id}/friend_survey.json", { friend_survey: @survey_params1 } )
      response = token.post("#{@endpoint}/games/#{game.id}/friend_survey.json", { friend_survey: @survey_params2 } )

      response = token.get("#{@endpoint}/games/#{game.id}/friend_survey.json" )
      response.status.should == 404
      result = JSON.parse(response.body, symbolize_names: true)
      result.should_not be_nil
    end

    it 'returns an error if the result is not calculated' do 
      token = get_conn()
      response = token.post("#{@endpoint}/games/#{game.id}/friend_survey.json", { friend_survey: @survey_params1 } )
      response = token.post("#{@endpoint}/games/#{game.id}/friend_survey.json", { friend_survey: @survey_params2 } )
      response = token.post("#{@endpoint}/games/#{game.id}/friend_survey.json", { friend_survey: @survey_params3 } )

      response = token.get("#{@endpoint}/games/#{game.id}/friend_survey.json" )
      response.status.should == 404
      result = JSON.parse(response.body, symbolize_names: true)
      result.should_not be_nil
    end

  end
end