require 'spec_helper'
require 'yaml'

module TidepoolAnalyze
  describe AnalyzeDispatcher do
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

    it 'should generate raw results from modules' do
      modules = @analyze_dispatcher.sort_events_to_modules(@events)
      raw_results = @analyze_dispatcher.raw_results(modules)
      raw_results.length.should == 3
      raw_results[:image_rank].should_not be_nil
      raw_results[:circles_test].should_not be_nil
      raw_results[:reaction_time].should_not be_nil
    end

    it 'should generate raw results in correct format' do
      modules = @analyze_dispatcher.sort_events_to_modules(@events)
      raw_results = @analyze_dispatcher.raw_results(modules)
      raw_results.each do |module_name, module_results |
        module_results.each do |module_result|
          module_result[:results].should_not be_nil
          module_result[:stage].should_not be_nil
        end
      end
    end

    it 'should generate aggregate results from raw results' do
      modules = @analyze_dispatcher.sort_events_to_modules(@events)
      raw_results = @analyze_dispatcher.raw_results(modules)
      aggregate_results = @analyze_dispatcher.aggregate_results(raw_results)
      aggregate_results.length.should == 3
    end

    it 'should generate aggregate results in correct format' do
      modules = @analyze_dispatcher.sort_events_to_modules(@events)
      raw_results = @analyze_dispatcher.raw_results(modules)
      aggregate_results = @analyze_dispatcher.aggregate_results(raw_results)
      #aggregate_results[:image_rank].should_not be_nil
      #aggregate_results[:circles_test].should_not be_nil
      #aggregate_results[:reaction_time].should_not be_nil
    end

    it 'should analyze from saved events' do
      results = @analyze_dispatcher.analyze(@events)
      results[:raw_results].should_not be_nil
      results[:aggregate_results].should_not be_nil
      results[:big5_score].should_not be_nil
      results[:holland6_score].should_not be_nil
    end

    describe 'Big5, Holland6 and Emo8 Calculations' do
      before(:all) do
        @aggregate_results = {
            image_rank: {
                Big5: {
                    Openness: { average: 10 },
                    Agreeableness: { average: 3 },
                    Conscientiousness: { average: 8 },
                    Extraversion: { average: 6 },
                    Neuroticism: { average: 1 }
                }
            },
            circles_test: {
                Big5: {
                    Openness: { average: 4 },
                    Agreeableness: { average: 6 },
                    Conscientiousness: { average: 2 },
                    Extraversion: { average: 1 },
                    Neuroticism: { average: 5 }
                },
                Holland6: {
                    Realistic: { average: 8 },
                    Artistic: { average: 12 },
                    Social: { average: 4 },
                    Enterprising: { average: 3 },
                    Investigative: { average: 1 },
                    Conventional: { average: 5 }
                }
            }
        }
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
      it 'should calculate the Big5 score correctly' do
        dimension = @analyze_dispatcher.calculate_big5(@aggregate_results)
        dimension.should == 'High Openness'
      end
      it 'should calculate the Holland6 score correctly' do
        dimension = @analyze_dispatcher.calculate_holland6(@aggregate_results)
        dimension.should == 'Artistic'
      end
      it 'should have the correct profile description' do
        big5_dimension = @analyze_dispatcher.calculate_big5(@aggregate_results)
        holland6_dimension = @analyze_dispatcher.calculate_holland6(@aggregate_results)

        profile = ProfileDescription.where('big5_dimension = ? AND holland6_dimension = ?', big5_dimension, holland6_dimension).first
        profile.should_not be_nil
        profile.name.should == 'The Different Drummer'
      end
    end
  end
end