require 'spec_helper'
require 'oauth2'


describe 'Results API' do 
  def get_token
    client = OAuth2::Client.new(@app.uid, @app.secret) do |b|
      b.request :url_encoded
      b.adapter :rack, Rails.application
    end   
    token = client.password.get_token(@user_email, @user_pass)
  end

  def create_assessment(caller, user)
    definition = Definition.find_or_return_default(nil)
    assessment = Assessment.create_by_caller(definition, caller, user)
    assessment.add_to_user(caller, user)
    assessment.save!
    assessment
  end

  before :all do 
    @user_email = 'user@example.com'
    @user_pass = 'tidepool'
    @user2_email = 'user2@example.com'
    @user2_pass = 'tidepool'
    @admin_email = 'admin@example.com'
    @admin_pass = 'tidepool'

    @user = User.where('email = ?', @user_email).first
    @user2 = User.where('email = ?', @user2_email).first
    @admin = User.where('email = ?', @admin_email).first

    @app = Doorkeeper::Application.where('name = ?', 'tidepool_test').first_or_create do |app|
      app.name = 'tidepool_test'
      app.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
    end
    @app.save! 
  end

  it 'should be able to start the results calculation' do 
    ResultsCalculator.stub(:performAsync) do |assessment_id|
      assessment = Assessment.find(assessment_id)
      assessment.status = :results_ready
      assessment.save!
    end

    assessment = create_assessment(@user, @user)
    token = get_token    
    response = token.post("/api/v1/assessments/#{assessment.id}/results.json")
    response.status.should == 202
  end

  it 'should be able to keep checking progress' do
    ResultsCalculator.stub(:performAsync) do |assessment_id|
      assessment = Assessment.find(assessment_id)
      assessment.status = :completed
      assessment.save!
    end

    assessment = create_assessment(@user, @user)
    token = get_token    
    response = token.post("/api/v1/assessments/#{assessment.id}/results.json")
    status = JSON.parse(response.body, :symbolize_names => true)
    progress_url = "#{status[:status][:link]}.json"
    response = token.get(progress_url)
    response.status.should == 200
    status = JSON.parse(response.body, :symbolize_names => true)
    status[:status][:state].should == 'pending'
  end

  it 'should be able to get the show url from progress endpoint' do
    assessment = create_assessment(@user, @user)
    assessment.status = :results_ready
    assessment.save!

    token = get_token

    progress_url = "/api/v1/assessments/#{assessment.id}/progress.json"
    response = token.get(progress_url)
    response.status.should == 200

    status = JSON.parse(response.body, :symbolize_names => true)
    status[:status][:link].should == "http://example.org#{progress_url}".chomp('.json')

    expected_url = "http://example.org/api/v1/assessments/#{assessment.id}/results"
    response.headers['Location'].should == expected_url
  end

  it 'should be able to get the error state if results are not calculated from progress url' do
    assessment = create_assessment(@user, @user)
    assessment.status = :no_results
    assessment.save!

    token = get_token

    progress_url = "/api/v1/assessments/#{assessment.id}/progress.json"
    response = token.get(progress_url)
    response.status.should == 200
    status = JSON.parse(response.body, :symbolize_names => true)
    status[:status][:state].should == 'error'
    status[:status][:link].should == "http://example.org#{progress_url}".chomp('.json')
  end

  it 'should be able to show the results if they are calculated' do
    assessment = create_assessment(@user, @user)
    assessment.status = :results_ready
    assessment.intermediate_results = "Hello World"
    assessment.save!

    token = get_token

    results_url = "/api/v1/assessments/#{assessment.id}/results.json"
    response = token.get(results_url)
    response.status.should == 200
    
    results = JSON.parse(response.body, :symbolize_names => true)
    results[:intermediate_results].should == assessment.intermediate_results
  end

end