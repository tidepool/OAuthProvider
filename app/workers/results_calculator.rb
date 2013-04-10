require 'redis'
require 'json'
require 'tidepool_analyze'
Dir[File.expand_path('../persistence/*.rb', __FILE__)].each {|file| require file }

class ResultsCalculator
  include Sidekiq::Worker
   
  MAX_NUM_EVENTS = 10000
  CURRENT_ANALYSIS_VERSION = '1.0'
 
  def perform(assessment_id)
    key = "assessment:#{assessment_id}"
    # Get the user events for a given assessment
    # TODO: DONOT forget to remove the items from Redis after calculation ends with success
    user_events_json = $redis.lrange(key, 0, MAX_NUM_EVENTS)
    user_events = []
    user_events_json.each do |user_event| 
      user_events << JSON.parse(user_event)
    end
    
    # Get the elements and circles information
    elements = {}
    Element.where(version: CURRENT_ANALYSIS_VERSION).each do |entry|
      elements[entry[:name]] = ::OpenStruct.new(entry.attributes) 
    end
    circles = {}
    AdjectiveCircle.where(version: CURRENT_ANALYSIS_VERSION).each do |entry|
      circles[entry[:name_pair]] = ::OpenStruct.new(entry.attributes)
    end
    binding.pry

    assessment = Assessment.find(assessment_id)
    analyze_dispatcher = TidepoolAnalyze::AnalyzeDispatcher.new(assessment.definition.stages, elements, circles)
    
    score_names = assessment.definition.score_names

    results = analyze_dispatcher.analyze(user_events, score_names)

    assessment.definition.calculates.each do |calculation|
      klass_name = "Persist#{calculation.to_s.camelize}"
      begin
        persist_calculation = klass_name.constantize.new()
        persist_calculation.persist(assessment, results)
      rescue Exception => e
        raise e
      end
    end    

    assessment.status = :results_ready
    assessment.save
  end
end
