require 'spec_helper'

module TidepoolAnalyze
  module Analyzer

    describe 'Image Rank Analyzer: ' do
      before(:all) do
        events_json = IO.read(File.expand_path('../../fixtures/test_event_log.json', __FILE__))
        events = JSON.parse(events_json).find_all { |event| event['module'] == 'image_rank'}
        @analyzer = ImageRankAnalyzer.new(events)
      end

      it 'should record the test start time with test start date 2013' do
        # Do a quick reality check
        # Note: JS time is reported in ms, Ruby is in sec for Epoch time
        start_time = Time.at(@analyzer.start_time/1000)
        # TODO: This test will start failing in 2013
        start_time.year.should equal(2013)
      end

      it 'should record the test end time and greater than start_time' do
        start_time = Time.at(@analyzer.start_time/1000)    
        end_time = Time.at(@analyzer.end_time/1000)
        (end_time - start_time).should be > 0
      end

      it 'should have a final rank' do
        @analyzer.final_rank.length.should equal(5)
        ranks_exist = {}
        @analyzer.final_rank.each { |rank| ranks_exist[rank.to_s] = 1 }
        (0..4).each { |number| ranks_exist[number.to_s].should equal(1) }
      end

      it 'should have the image sequence' do
        @analyzer.images.length.should equal(5)
      end

      describe 'Element Calculations: ' do
        before(:all) do
          events_json = <<JSONSTRING
[
  { "event_type":"0",
    "module":"image_rank",
    "stage":2,
    "record_time":1358880379112,
    "event_desc":"test_started",
    "image_sequence":[
      { "url":"assets/devtest_images/F1a.jpg",
        "elements":"male,man_made,movement,nature,pair",
        "image_id":"F1a","rank":-1},
      { "url":"assets/devtest_images/F1b.jpg",
        "elements":"color,male,pair,reflection",
        "image_id":"F1b","rank":-1},
      { "url":"assets/devtest_images/F1c.jpg",
        "elements":"color,human_eyes,male,reflection,texture",
        "image_id":"F1c","rank":-1},
      { "url":"assets/devtest_images/F1d.jpg",
        "elements":"color,happy,human,human_eyes,nature",
        "image_id":"F1d","rank":-1},
      { "url":"assets/devtest_images/F1e.jpg",
        "elements":"male,man_made,pair,reflection,whole",
        "image_id":"F1e","rank":-1}
        ],"assessment_id":329,"user_id":21},
  { "event_type":"0",
    "module":"image_rank",
    "stage":2,
    "record_time":1358880386090,
    "final_rank":[1,4,2,3,0],
    "event_desc":"test_completed",
    "assessment_id":329,"user_id":21}
]
JSONSTRING
          events = JSON.parse(events_json)
          @analyzer = ImageRankAnalyzer.new(events)
          @elements = %w(male man_made movement nature pair color reflection human_eyes texture happy whole human)
        end
        
        it 'should have the correct number of elements' do
          result = @analyzer.calculate_result()
          result.length.should == @elements.length
        end

        it 'should calculate the correct rank for element male' do
          result = @analyzer.calculate_result()
          result['male'].should == (4 + 1 + 3 + 5)
          result['human'].should == 2
        end
      end
    end
  end
end
