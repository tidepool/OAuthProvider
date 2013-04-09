require 'spec_helper'
require 'yaml'

module TidepoolAnalyze

  describe AnalyzeDispatcher do
    def calculate_aggregate_results
      modules = @analyze_dispatcher.sort_events_to_modules(@events)
      intermediate_results = @analyze_dispatcher.intermediate_results(modules)
      aggregate_results = @analyze_dispatcher.aggregate_results(intermediate_results)
    end

    before(:all) do
      events_json = IO.read(File.expand_path('../fixtures/event_log.json', __FILE__))
      @events = JSON.parse(events_json)
      stages_json = IO.read(File.expand_path('../fixtures/assessment.json', __FILE__))
      @stages = JSON.parse stages_json
      elements = YAML::load(IO.read(File.expand_path('../fixtures/elements.yaml', __FILE__)))
      new_elements = {}
      elements.each { |element, value| new_elements[element] = ::OpenStruct.new(value)}
      circles = YAML::load(IO.read(File.expand_path('../fixtures/circles.yaml', __FILE__)))
      new_circles = {}
      circles.each { |circle, value| new_circles[circle] = ::OpenStruct.new(value) }
      @analyze_dispatcher = AnalyzeDispatcher.new(@stages, new_elements, new_circles)
    end
    
    it 'should sort events into modules' do
      modules = @analyze_dispatcher.sort_events_to_modules(@events)
      modules.length.should == 8
    end

    it 'should generate intermediate results from modules' do
      modules = @analyze_dispatcher.sort_events_to_modules(@events)
      intermediate_results = @analyze_dispatcher.intermediate_results(modules)
      intermediate_results.length.should == 3
      intermediate_results[:image_rank].should_not be_nil
      intermediate_results[:circles_test].should_not be_nil
      intermediate_results[:reaction_time].should_not be_nil
    end

    it 'should generate intermediate results in correct format' do
      modules = @analyze_dispatcher.sort_events_to_modules(@events)
      intermediate_results = @analyze_dispatcher.intermediate_results(modules)
      intermediate_results.each do |module_name, module_results |
        module_results.each do |module_result|
          module_result[:results].should_not be_nil
          module_result[:stage].should_not be_nil
        end
      end
    end

    it 'should generate aggregate results from intermediate results' do
      aggregate_results = calculate_aggregate_results
      aggregate_results.length.should == 3
    end

    it 'should generate aggregate results for image_rank module in correct format' do
      aggregate_results = calculate_aggregate_results
      aggregate_results[:image_rank].should_not be_nil

      aggregate_results[:image_rank][:big5].should_not be_nil
      dimensions = [:openness, :agreeableness, :conscientiousness, :extraversion, :neuroticism]
      dimensions.each do |dimension|
        aggregate_results[:image_rank][:big5][dimension].should_not be_nil
      end
    end

    it 'should generate aggregate results for circles_test module in correct format' do
      aggregate_results = calculate_aggregate_results
      aggregate_results[:circles_test].should_not be_nil

      aggregate_results[:circles_test][:big5].should_not be_nil
      dimensions = [:openness, :agreeableness, :conscientiousness, :extraversion, :neuroticism]
      dimensions.each do |dimension|
        aggregate_results[:circles_test][:big5][dimension].should_not be_nil
      end

      aggregate_results[:circles_test][:holland6].should_not be_nil
      dimensions = [:realistic, :artistic, :social, :enterprising, :investigative, :conventional]
      dimensions.each do |dimension|
        aggregate_results[:circles_test][:holland6][dimension].should_not be_nil
      end
    end

    it 'should generate aggregate results for reaction_time module in correct format' do
      aggregate_results = calculate_aggregate_results
      aggregate_results[:reaction_time].should_not be_nil

      colors = [:red]
      colors.each do |color|
        aggregate_results[:reaction_time][color].should_not be_nil
        measures = [:total_clicks_with_threshold, :total_clicks, :total_correct_clicks_with_threshold,
          :average_time, :average_time_with_threshold, :average_correct_time_to_click,
          :at_results, :atwt_results, :actc_results]

        measures.each do |measure|
          aggregate_results[:reaction_time][color][measure].should_not be_nil
        end
      end
    end

    it 'should analyze from saved events' do
      score_names = ["big5", "holland6"]
      results = @analyze_dispatcher.analyze(@events, score_names)
      results[:event_log].should_not be_nil
      results[:intermediate_results].should_not be_nil
      results[:aggregate_results].should_not be_nil
      results[:scores].should_not be_nil
    end
  end
end