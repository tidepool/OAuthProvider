require 'spec_helper'
# require 'yaml'

module TidepoolAnalyze
  describe AnalyzeDispatcher do
    def run_analyzer(mini_game, formula_desc, analyzer_class)
      analyze_dispatcher = AnalyzeDispatcher.new
      mini_game_events = analyze_dispatcher.events_by_mini_game(@events)
      input_data = mini_game_events[mini_game]

      formula = TidepoolAnalyze::Utils::load_formula(formula_desc)

      results = analyze_dispatcher.run_analyzer(analyzer_class, formula, input_data)
    end

    def run_formulator(input_data, formula_desc, formulator_class)
      analyze_dispatcher = AnalyzeDispatcher.new
      formula = TidepoolAnalyze::Utils::load_formula(formula_desc)
      analyze_dispatcher.run_formulator(formulator_class, formula, input_data)
    end

    def run_score_generator(score_name, input_data)
      analyze_dispatcher = AnalyzeDispatcher.new
      analyze_dispatcher.run_score_generator(score_name, input_data)
    end

    def execute_recipe(recipe_name)
      analyze_dispatcher = AnalyzeDispatcher.new
      mini_game_events = analyze_dispatcher.events_by_mini_game(@events)
      recipe = analyze_dispatcher.read_recipe recipe_name
      analysis = analyze_dispatcher.execute_recipe(recipe, recipe_name, mini_game_events)
    end

    before(:all) do
      events_json = IO.read(File.expand_path('../fixtures/test_event_log.json', __FILE__))
      @events = JSON.parse(events_json)
    end
    
    it 'sorts user_events into mini_game_events' do
      analyze_dispatcher = AnalyzeDispatcher.new
      mini_game_events = analyze_dispatcher.events_by_mini_game(@events)
      mini_game_events.length.should == 4
      mini_game_events['reaction_time'].should_not be_nil
      mini_game_events['reaction_time'].length.should == 2
      mini_game_events['reaction_time'].each do |stage, stage_events|
        stage_events.length.should == 29 if stage == 0
        stage_events.length.should == 16 if stage == 1
        stage_events[0]['module'].should == 'reaction_time'
      end
      mini_game_events['image_rank'].should_not be_nil
      mini_game_events['image_rank'].length.should == 1
      mini_game_events['circles_test'].should_not be_nil
      mini_game_events['circles_test'].length.should == 5
      mini_game_events['survey'].should_not be_nil
      mini_game_events['survey'].length.should == 1

    end

    it 'reads the recipes for given score_name' do
      analyze_dispatcher = AnalyzeDispatcher.new
      recipe = analyze_dispatcher.read_recipe 'big5'
      recipe.length.should == 2
      recipe[0][:user_event_source].should == 'circles_test'
      recipe[0][:analyzer].should == 'CirclesTestAnalyzer'
      recipe[0][:formulator].should == 'CirclesFormulator'
      recipe[0][:formula_sheet].should == 'big5_circles.csv'
      recipe[0][:formula_key].should == 'name_pair'
    end

    it 'runs the analyzer for big5 circles_test' do
      formula_desc = {
              formula_sheet: 'big5_circles.csv',
              formula_key: 'name_pair' }

      results = run_analyzer('circles_test', formula_desc, "CirclesTestAnalyzer")
      results.length.should == 2 # Two stages of Big5 circles
      results.each do |result|
        result.each do |result_obj|
          result_obj[:name_pair].should_not be_nil
          result_obj[:size].should_not be_nil
          result_obj[:distance].should_not be_nil
          result_obj[:overlap].should_not be_nil
          result_obj[:distance_standard].should_not be_nil
          result_obj[:distance_rank].should_not be_nil
        end
      end
    end

    it 'runs the analyzer for holland6 circles_test' do
      formula_desc = {
              formula_sheet: 'holland6_circles.csv',
              formula_key: 'name_pair' }

      results = run_analyzer('circles_test', formula_desc, "CirclesTestAnalyzer")
      results.length.should == 1 # One stages of Big5 circles
      results.each do |result|
        result.each do |result_obj|
          result_obj[:name_pair].should_not be_nil
          result_obj[:size].should_not be_nil
          result_obj[:distance].should_not be_nil
          result_obj[:overlap].should_not be_nil
          result_obj[:distance_standard].should_not be_nil
          result_obj[:distance_rank].should_not be_nil
        end
      end
    end

    it 'runs the analyzer for big5 image_rank' do
      formula_desc = {
              formula_sheet: 'elements.csv',
              formula_key: 'name' }

      results = run_analyzer('image_rank', formula_desc, "ImageRankAnalyzer")
      results.length.should == 1 # One stage of Big5 circles
      results.each do |result|
        result['color'].should == 15
        result['human'].should == 14
        result['male'].should == 13
      end
    end


    it 'runs the formulator for the big5 circles_test' do
      formula_desc = {
              formula_sheet: 'big5_circles.csv',
              formula_key: 'name_pair' }

      results = run_analyzer('circles_test', formula_desc, "CirclesTestAnalyzer")
      result = run_formulator(results, formula_desc, "CirclesFormulator")
      result[:conscientiousness].should_not be_nil
      result[:neuroticism].should_not be_nil
      result[:openness].should_not be_nil
      result[:agreeableness].should_not be_nil
      result[:extraversion].should_not be_nil
      result[:conscientiousness][:weighted_total].should_not be_nil
      result[:conscientiousness][:count].should == 2
      result[:conscientiousness][:average].should == result[:conscientiousness][:weighted_total] / result[:conscientiousness][:count]
    end

    it 'runs the formulator for the holland6 circles_test' do
      formula_desc = {
              formula_sheet: 'holland6_circles.csv',
              formula_key: 'name_pair' }

      results = run_analyzer('circles_test', formula_desc, "CirclesTestAnalyzer")
      result = run_formulator(results, formula_desc, "CirclesFormulator")
      result[:realistic].should_not be_nil
      result[:artistic].should_not be_nil
      result[:social].should_not be_nil
      result[:enterprising].should_not be_nil
      result[:investigative].should_not be_nil
      result[:conventional].should_not be_nil

      result[:realistic][:weighted_total].should_not be_nil
      result[:realistic][:count].should == 1
      result[:realistic][:average].should == result[:realistic][:weighted_total] / result[:realistic][:count]
    end

    it 'runs the formulator for the big5 image_rank' do
      formula_desc = {
              formula_sheet: 'elements.csv',
              formula_key: 'name' }

      results = run_analyzer('image_rank', formula_desc, "ImageRankAnalyzer")
      result = run_formulator(results, formula_desc, "ElementFormulator")
      result[:conscientiousness].should_not be_nil
      result[:neuroticism].should_not be_nil
      result[:openness].should_not be_nil
      result[:agreeableness].should_not be_nil
      result[:extraversion].should_not be_nil
      result[:conscientiousness][:weighted_total].should_not be_nil
      result[:conscientiousness][:count].should == 9
      result[:conscientiousness][:average].should == result[:conscientiousness][:weighted_total] / result[:conscientiousness][:count]
    end

    it 'runs the score generator for big5 using image_rank test only' do 
      formula_desc = {
              formula_sheet: 'elements.csv',
              formula_key: 'name' }

      results = run_analyzer('image_rank', formula_desc, "ImageRankAnalyzer")
      result = run_formulator(results, formula_desc, "ElementFormulator")
      score_input = []
      score_input << result
      score = run_score_generator('big5', score_input)
      score[:dimension].should_not be_nil
      score[:dimension_values].should_not be_nil
      score[:low_dimension].should_not be_nil
      score[:high_dimension].should_not be_nil
      score[:adjust_by].should_not be_nil
    end

    it 'runs the score generator for big5 using circles_test test only' do 
      formula_desc = {
              formula_sheet: 'big5_circles.csv',
              formula_key: 'name_pair' }

      results = run_analyzer('circles_test', formula_desc, "CirclesTestAnalyzer")
      result = run_formulator(results, formula_desc, "CirclesFormulator")
      score_input = []
      score_input << result
      score = run_score_generator('big5', score_input)
      score[:dimension].should_not be_nil
      score[:dimension_values].should_not be_nil
      score[:low_dimension].should_not be_nil
      score[:high_dimension].should_not be_nil
      score[:adjust_by].should_not be_nil
    end

    it 'runs the score generator for holland6 using circles_test test' do 
      formula_desc = {
              formula_sheet: 'holland6_circles.csv',
              formula_key: 'name_pair' }

      results = run_analyzer('circles_test', formula_desc, "CirclesTestAnalyzer")
      result = run_formulator(results, formula_desc, "CirclesFormulator")
      score_input = []
      score_input << result
      score = run_score_generator('holland6', score_input)
      score[:dimension].should_not be_nil
      score[:dimension_values].should_not be_nil
      score[:adjust_by].should_not be_nil
    end

    it 'executes a big5 recipe' do
      analysis = execute_recipe('big5')

      analysis[:final_results].should_not be_nil
      analysis[:score].should_not be_nil
    end

    it 'executes a holland6 recipe' do
      analysis = execute_recipe('holland6')

      analysis[:final_results].should_not be_nil
      analysis[:score].should_not be_nil
    end

    it 'executes a reaction_time recipe' do 
      analysis = execute_recipe('reaction_time')      
      analysis.should_not be_nil
      analysis[:final_results].length.should == 2
      analysis[:final_results][0][:demand].should_not be_nil

      analysis[:final_results][1][:min_time].should_not be_nil

      analysis[:score].should_not be_nil
    end

    it 'executes a capacity recipe' do
      analysis = execute_recipe('capacity')
      analysis.should_not be_nil

    end

    it 'analyzes the user_events and scores' do
      score_names = ['big5', 'holland6']

      analyze_dispatcher = AnalyzeDispatcher.new
      analysis = analyze_dispatcher.analyze(@events, score_names)
      analysis.length.should == 2
      analysis[:big5].should_not be_nil
      analysis[:holland6].should_not be_nil
      analysis[:big5][:score].should_not be_nil
      analysis[:holland6][:score].should_not be_nil
    end  

    # it 'should generate intermediate results from modules' do
    #   modules = @analyze_dispatcher.sort_events_to_modules(@events)
    #   intermediate_results = @analyze_dispatcher.intermediate_results(modules)
    #   intermediate_results.length.should == 3
    #   intermediate_results[:image_rank].should_not be_nil
    #   intermediate_results[:circles_test].should_not be_nil
    #   intermediate_results[:reaction_time].should_not be_nil
    # end

    # it 'should generate intermediate results in correct format' do
    #   modules = @analyze_dispatcher.sort_events_to_modules(@events)
    #   intermediate_results = @analyze_dispatcher.intermediate_results(modules)
    #   intermediate_results.each do |module_name, module_results |
    #     module_results.each do |module_result|
    #       module_result[:results].should_not be_nil
    #       module_result[:stage].should_not be_nil
    #     end
    #   end
    # end

    # it 'should generate aggregate results from intermediate results' do
    #   aggregate_results = calculate_aggregate_results
    #   aggregate_results.length.should == 3
    # end

    # it 'should generate aggregate results for image_rank module in correct format' do
    #   aggregate_results = calculate_aggregate_results
    #   aggregate_results[:image_rank].should_not be_nil

    #   aggregate_results[:image_rank][:big5].should_not be_nil
    #   dimensions = [:openness, :agreeableness, :conscientiousness, :extraversion, :neuroticism]
    #   dimensions.each do |dimension|
    #     aggregate_results[:image_rank][:big5][dimension].should_not be_nil
    #   end
    # end

    # it 'should generate aggregate results for circles_test module in correct format' do
    #   aggregate_results = calculate_aggregate_results
    #   aggregate_results[:circles_test].should_not be_nil

    #   aggregate_results[:circles_test][:big5].should_not be_nil
    #   dimensions = [:openness, :agreeableness, :conscientiousness, :extraversion, :neuroticism]
    #   dimensions.each do |dimension|
    #     aggregate_results[:circles_test][:big5][dimension].should_not be_nil
    #   end

    #   aggregate_results[:circles_test][:holland6].should_not be_nil
    #   dimensions = [:realistic, :artistic, :social, :enterprising, :investigative, :conventional]
    #   dimensions.each do |dimension|
    #     aggregate_results[:circles_test][:holland6][dimension].should_not be_nil
    #   end
    # end

    # it 'should generate aggregate results for reaction_time module in correct format' do
    #   aggregate_results = calculate_aggregate_results
    #   aggregate_results[:reaction_time].should_not be_nil

    #   colors = [:red]
    #   colors.each do |color|
    #     aggregate_results[:reaction_time][color].should_not be_nil
    #     measures = [:total_clicks_with_threshold, :total_clicks, :total_correct_clicks_with_threshold,
    #       :average_time, :average_time_with_threshold, :average_correct_time_to_click,
    #       :at_results, :atwt_results, :actc_results]

    #     measures.each do |measure|
    #       aggregate_results[:reaction_time][color][measure].should_not be_nil
    #     end
    #   end
    # end

    # it 'should analyze from saved events' do
    #   score_names = ["big5", "holland6"]
    #   results = @analyze_dispatcher.analyze(@events, score_names)
    #   results[:event_log].should_not be_nil
    #   results[:intermediate_results].should_not be_nil
    #   results[:aggregate_results].should_not be_nil
    #   results[:scores].should_not be_nil
    # end
  end
end