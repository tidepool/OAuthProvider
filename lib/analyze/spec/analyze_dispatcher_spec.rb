require 'spec_helper'
# require 'yaml'

module TidepoolAnalyze
  describe AnalyzeDispatcher do
    def load_event_fixtures(filename) 
      events_json = IO.read(File.expand_path("../fixtures/#{filename}", __FILE__))
      events = JSON.parse(events_json)
    end

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
      analysis[:score].should == {
        :dimension => "low_conscientiousness",
        :dimension_values => {
            :openness => 13.545517101280748,
            :agreeableness => 18.956322022270864,
            :conscientiousness => 10.0,
            :extraversion => 22.453501732805346,
            :neuroticism => 21.267963651267777 },
        :low_dimension => :conscientiousness,
        :high_dimension => :extraversion,
        :adjust_by => 1.7080919421487604,
        :version => "2.0"
      }
    end

    it 'executes a big5_with_images recipe' do 
      analysis = execute_recipe('big5_with_images')

      analysis[:final_results].should_not be_nil
      analysis[:score].should_not be_nil
    end

    it 'executes a holland6 recipe' do
      analysis = execute_recipe('holland6')

      analysis[:final_results].should_not be_nil
      analysis[:score].should_not be_nil
    end

    it 'executes a holland6_new recipe with the Interest Picker' do 
      analysis = execute_recipe('holland6_new')

      analysis[:final_results].should_not be_nil
      analysis[:score].should_not be_nil
    end

    it 'executes a reaction_time recipe' do 
      analysis = execute_recipe('reaction_time')   
      analysis.should_not be_nil
      analysis[:final_results].length.should == 2
      analysis[:final_results][0].should == {
        :demand=> {:answer=>5, :zscore=>0.6709893546422306, :tscore=>51.1827730651085},
        :productivity=>{:answer=>3},
        :stress=> {:answer=>2}
      }

      analysis[:final_results][1].should == { 
        :total_average_time_zscore=>-0.3573482938607396,
        :total_average_time=>1310,
        :average_time=>655,
        :min_time=>532,
        :max_time=>905
      }

      analysis[:score].should_not be_nil
    end

    it 'executes a reaction_time recipe with snoozer events' do 
      analyze_dispatcher = AnalyzeDispatcher.new
      events = load_event_fixtures('snoozer.json')
      mini_game_events = analyze_dispatcher.events_by_mini_game(events)
      recipe = analyze_dispatcher.read_recipe 'reaction_time'
      analysis = analyze_dispatcher.execute_recipe(recipe, 'reaction_time', mini_game_events)
      analysis.should_not be_nil
      analysis[:score].should == {:fastest_time=>300, :slowest_time=>500, :average_time=>400, :version=>"2.0" }
    end


    it 'executes a capacity recipe' do
      analysis = execute_recipe('capacity')
      analysis.should_not be_nil

    end

    it 'calculates the big5 and holland6 scores' do
      score_names = ['big5', 'holland6']

      analyze_dispatcher = AnalyzeDispatcher.new
      analysis = analyze_dispatcher.analyze(@events, score_names)
      analysis.length.should == 2
      analysis[:big5].should_not be_nil
      analysis[:holland6].should_not be_nil
      analysis[:big5][:score].should_not be_nil
      analysis[:holland6][:score].should_not be_nil
    end  

    it 'calculates the holland6_new score' do
      score_names = ['holland6_new']

      analyze_dispatcher = AnalyzeDispatcher.new
      analysis = analyze_dispatcher.analyze(@events, score_names)
      analysis.length.should == 1
      analysis[:holland6_new].should_not be_nil
    end

    it 'calculates the reaction_time score' do
      score_names = ['reaction_time']

      analyze_dispatcher = AnalyzeDispatcher.new
      analysis = analyze_dispatcher.analyze(@events, score_names)      
      analysis.length.should == 1
      analysis[:reaction_time].should_not be_nil
      analysis[:reaction_time][:score].should_not be_nil
      analysis[:reaction_time][:final_results].should_not be_nil 
      analysis[:reaction_time][:score][:version].should == '2.0'
      score = analysis[:reaction_time][:score]
      final_results = analysis[:reaction_time][:final_results]
      final_results.length.should > 0

      score[:fastest_time].should_not be_nil
      score[:slowest_time].should_not be_nil
      score[:average_time].should_not be_nil
    end

    it 'calculates the survey score' do 
      score_names = ['survey']
      analyze_dispatcher = AnalyzeDispatcher.new

      analysis = analyze_dispatcher.analyze(@events, score_names)   
      analysis.length.should == 1
      analysis[:survey][:score].should == {
        :demand => {:answer=>5, :zscore=>0.6709893546422306, :tscore=>51.1827730651085},
        :productivity => {:answer=>3},
        :stress => {:answer=>2},
        :version =>"2.0"
      }
    end

    it 'calculates the emotion score' do 
      score_names = ['emo']
      events = load_event_fixtures('emotions.json')
      analyze_dispatcher = AnalyzeDispatcher.new
      analysis = analyze_dispatcher.analyze(events, score_names)      
      analysis.should_not be_nil
      analysis[:emo][:score].should == {
        :factors=> {
          :factor1=>41.66610693205314,
          :factor2=>44.92791625293482,
          :factor3=>45.71085593272107,
          :factor4=>46.654220307040134,
          :factor5=>46.58723907733867},
        :weakest_emotion=>
          {:emotion=>"amused", :distance_standard=>1.421512765416739},
        :strongest_emotion=>
          {:emotion=>"awe", :distance_standard=>0.3851313146973706},
        :reported_emotion=>"sadness",
        :calculated_emotion=>"awe",
        :version=>"2.0"
      }

      analysis[:emo][:final_results].should_not be_nil
      analysis[:emo][:final_results][0][:emo_distances].should == {
        :amused=>1.421512765416739,
        :awe=>0.3851313146973706,
        :anger=>0.6871490010404313,
        :boredom=>0.7060739719579999,
        :confused=>1.421512765416739,
        :contentment=>0.3851313146973706,
        :coyness=>0.6871490010404313,
        :desire_food=>0.7154387934587391,
        :desire_sex=>1.421512765416739,
        :disgust=>0.3851313146973706,
        :embarrassment=>0.6871490010404313,
        :fear=>0.7154387934587391,
        :happiness=>1.421512765416739,
        :interest=>0.3851313146973706,
        :pain=>0.6871490010404313,
        :pride=>0.7154387934587391,
        :relief=>0.8568200008399066,
        :sadness=>1.421512765416739,
        :shame=>0.3851313146973706,
        :surprise=>0.6871490010404313,
        :sympathy=>0.7154387934587391,
        :triumph=>0.8568200008399066
      }
    end

    it 'calculates the capacity score' do
      score_names = ['capacity']

      analyze_dispatcher = AnalyzeDispatcher.new
      analysis = analyze_dispatcher.analyze(@events, score_names)      
      analysis.length.should == 1
      analysis[:capacity].should_not be_nil
      analysis[:capacity][:score].should_not be_nil
      analysis[:capacity][:final_results].should_not be_nil 
      analysis[:capacity][:score][:version].should == '2.0'
      score = analysis[:capacity][:score]
      final_results = analysis[:capacity][:final_results]
      final_results.length.should > 0

      score[:demand].should_not be_nil
    end
  end
end