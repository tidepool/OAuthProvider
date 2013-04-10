require 'spec_helper'
require Rails.root + 'app/models/events/user_event.rb'

require 'pry' if Rails.env.test? || Rails.env.development?

describe ResultsCalculator do
  def setup_users
    user_email = 'user@example.com'
    user2_email = 'user2@example.com'
    user = User.where('email = ?', user_email).first
    user2 = User.where('email = ?', user2_email).first
    return user, user2
  end

  def record_events_in_redis(assessment, events)
    UserEvent.cleanup(assessment.id)

    # Store the events in the Redis
    events.each do |event|
      user_event = UserEvent.new(event)

      # The user events are loaded from a saved file, so update the assessment id with what we created
      user_event.assessment_id = assessment.id
      user_event.record
    end
  end

  before(:all) do
    events_json = IO.read(File.expand_path('../../fixtures/test_event_log.json', __FILE__))
    events = JSON.parse(events_json)

    definition = Definition.first
    user, user2 = setup_users
    assessment = Assessment.create_by_caller(definition, user, user)
    record_events_in_redis(assessment, events)
    @assessment_id = assessment.id
  end

  it 'should calculate the results and the profile description' do
    resultsCalc = ResultsCalculator.new 

    assessment = Assessment.find(@assessment_id)
    assessment.status.should == :not_started.to_s
    resultsCalc.perform(@assessment_id)

    updatedAssessment = Assessment.find(@assessment_id)
    updatedAssessment.status.should == :results_ready.to_s
    updatedAssessment.result.should_not be_nil
    updatedAssessment.result.profile_description.should_not be_nil
    # Below result depends on the exact dataset we fed from test_event_log.json
    updatedAssessment.result.profile_description.name.should == "The Floodlight"
  end
end