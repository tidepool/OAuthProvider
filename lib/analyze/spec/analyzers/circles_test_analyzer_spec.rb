require 'spec_helper'

module TidepoolAnalyze
  module Analyzer

    describe 'Circles Test Analyzer' do
      before(:all) do
        events_json = IO.read(File.expand_path('../../fixtures/test_event_log.json', __FILE__))
        events = JSON.parse(events_json).find_all { |event| event['module'] == 'circles_test'}
        @analyzer = CirclesTestAnalyzer.new(events)

        @NUM_OF_LEVELS = 5
        @GROW_BY = 12
        @CIRCLE_SIZE = 156
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

      it 'should have the right sizes for circles' do
        circles = @analyzer.circles
        circles.each do |circle|
          delta = (@NUM_OF_LEVELS - 1 - circle['size']) * @GROW_BY
          correct_size = @CIRCLE_SIZE - delta
          correct_size.should == circle['width']
        end
      end

      describe 'Calculations' do
        before(:all) do
          events_json = <<JSONString
[
  {"event_type":"0","module":"circles_test","stage":3,"record_time":1358927109277,"event_desc":"test_started","game_id":340,"user_id":21},
  {"event_type":"0","module":"circles_test","stage":3,"record_time":1358927182747,"event_desc":"move_circles_started","circles":[{"trait1":"Self-Disciplined","trait2":"Persistent","size":2,"changed":true,"moved":false,"top":130,"left":145,"width":132,"height":132,"textMarginTop":33,"sliderMarginLeft":38},{"trait1":"Anxious","trait2":"Dramatic","size":0,"changed":true,"moved":false,"top":142,"left":387,"width":108,"height":108,"textMarginTop":21,"sliderMarginLeft":26},{"trait1":"Curious","trait2":"Cultured","size":1,"changed":true,"moved":false,"top":271,"left":266,"width":120,"height":120,"textMarginTop":27,"sliderMarginLeft":32},{"trait1":"Sociable","trait2":"Adventurous","size":4,"changed":true,"moved":false,"top":388,"left":133,"width":156,"height":156,"textMarginTop":45,"sliderMarginLeft":50},{"trait1":"Cooperative","trait2":"Friendly","size":3,"changed":true,"moved":false,"top":394,"left":369,"width":144,"height":144,"textMarginTop":39,"sliderMarginLeft":44}],"game_id":340,"user_id":21},
  {"event_type":"0","module":"circles_test","stage":3,"record_time":1358927310488,"event_desc":"test_completed","circles":[{"trait1":"Self-Disciplined","trait2":"Persistent","size":2,"changed":true,"moved":true,"top":209,"left":335,"width":132,"height":132,"textMarginTop":33,"sliderMarginLeft":38},{"trait1":"Anxious","trait2":"Dramatic","size":0,"changed":true,"moved":true,"top":283,"left":884,"width":108,"height":108,"textMarginTop":21,"sliderMarginLeft":26},{"trait1":"Curious","trait2":"Cultured","size":1,"changed":true,"moved":true,"top":165,"left":627,"width":120,"height":120,"textMarginTop":27,"sliderMarginLeft":32},{"trait1":"Sociable","trait2":"Adventurous","size":4,"changed":true,"moved":true,"top":68,"left":923,"width":156,"height":156,"textMarginTop":45,"sliderMarginLeft":50},{"trait1":"Cooperative","trait2":"Friendly","size":3,"changed":true,"moved":true,"top":376,"left":733,"width":144,"height":144,"textMarginTop":39,"sliderMarginLeft":44}],"self_coord":{"top":138,"left":693,"size":386},"game_id":340,"user_id":21}
]
JSONString
          events = JSON.parse(events_json)
          @analyzer = CirclesTestAnalyzer.new(events)
          @results = @analyzer.calculate_result
        end

        it 'should have one fully overlapped circle with self circle' do
          overlapped = @analyzer.overlapped_circles(1.0)
          overlapped.length.should == 1
          overlapped[0][:trait1].should == 'Anxious'
        end

        it 'should have one no-overlapped circle with self circle' do
          overlapped = @analyzer.overlapped_circles(0.0)
          overlapped.length.should == 1
          overlapped[0][:trait1].should == 'Self-Disciplined'
        end

        it 'should have one overlapped circle between 50% - 100%' do
          overlapped = @analyzer.overlapped_circles(0.5, 1.0)
          overlapped.length.should == 1
          overlapped[0][:trait1].should == 'Cooperative'
        end

        it 'should have one overlapped circle between 0% - 50%' do
          overlapped = @analyzer.overlapped_circles(0.0, 0.5)
          overlapped.length.should == 2
          traits = overlapped.find_all { |result| result[:trait1] == "Sociable" }
          traits[0][:trait1].should == "Sociable"  
        end

        it 'should find the closest circle to self circle' do
          closest_circle = @analyzer.closest_circle

          closest_circle[:trait1].should == "Anxious"
        end

        it 'should find the furthest circle to self circle' do
          furthest_circle = @analyzer.furthest_circle

          furthest_circle[:trait1].should == "Self-Disciplined"
        end

        it 'should create ranks for circles based on how far they are from self relative to each other' do
          expected_rank = {"Anxious" => 1, "Cooperative" => 2, "Sociable" => 3, "Curious" => 4, "Self-Disciplined" => 5}
          @results.each do |result|
            expected_rank[result[:trait1]].should == result[:distance_rank]
          end
        end
      end
    end
  end
end