require 'redis'
require 'json'
require 'tidepool_analyze'

ACTION_EVENT_QUEUE = 'action_events'
MAX_NUM_EVENTS = 10000

desc 'Analyze Test'
task :analyze_test => :environment do |t|
  puts 'analyze running'

  $redis_analyze.subscribe(ACTION_EVENT_QUEUE) do |on|
    on.message do |channel, msg|
      data = JSON.parse(msg)
      puts "Message received at ##{channel} - #{data['assessment_id']}"

      assessment = Assessment.find(data['assessment_id'])
      key = "assessment:#{data['assessment_id']}"
      user_events_json = $redis.lrange(key, 0, MAX_NUM_EVENTS)
      
      assessment.event_log = user_events_json
      if Rails.env.development? || Rails.env.test? 
        #date = DateTime.now
        # stamp = date.strftime("%Y%m%d_%H%M")
        log_file_path = Rails.root.join('spec', 'lib', 'tasks', 'fixtures', 'event_log.json')
        File.open(log_file_path, 'w+') do |file|
          output = "[\n"
          user_events_json.each { |event| output += "#{event},\n" }
          output.chomp!(",\n")
          output += "\n]"
          file.write output  
        end
      end

      elements = {}
      Element.where(version: @current_analysis_version).each do |entry|
        elements[entry[:name]] = entry.attributes 
      end
      circles = {}
      AdjectiveCircle.where(version: @current_analysis_version).each do |entry|
        circles[entry[:name_pair]] = entry.attributes
      end

      analyze_dispatcher = AnalyzeDispatcher.new(assessment.definition.stages, elements, circles)
      
      user_events = []
      user_events_json.each do |user_event| 
        user_events << JSON.parse(user_event)
      end
      results = analyze_dispatcher.analyze(user_events)
      assessment.intermediate_results = results[:raw_results]
      assessment.aggregate_results = results[:aggregate_results]
      assessment.big5_dimension = results[:big5_score]
      assessment.holland6_dimension = results[:holland6_score]
      #assessment.emo8_dimension = results[:emo8_score]
      assessment.profile_description = ProfileDescription.where('big5_dimension = ? AND holland6_dimension = ?', assessment.big5_dimension, assessment.holland6_dimension).first
      assessment.results_ready = true
      assessment.save

      # user = User.find(data['user_id'])
      # user.profile_description = assessment.profile_description
      # user.save
    end
  end
  puts 'analyze finished'
end