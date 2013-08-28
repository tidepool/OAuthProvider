require 'spec_helper'

describe PersistSpeedArchetype do
  let(:user) { create(:user) }
  let(:game) { create(:game, user: user) }
  let(:personality) { create(:personality, user: user) }
  let(:aggregate_result) { create(:aggregate_result, user: user) }

  before(:each) do 
    @analysis_results = {
      reaction_time2: {
        score: {
          :average_time=>529,
          :average_time_simple=>340,
          :average_time_complex=>718,
          :fastest_time=>400,
          :slowest_time=>905,
          :speed_score=>800,
          :version => "2.0"
        },
        final_results: [
          {
            :average_time=>529,
            :average_time_simple=>340,
            :average_time_complex=>718,
            :fastest_time=>400,
            :slowest_time=>905
          }
        ]
      }
    }
  end

  it 'persists the speed_archetype results' do 
    user
    persist_rt = PersistSpeedArchetype.new
    persist_rt.persist(game, @analysis_results)

    updated_game = Game.find(game.id)
    updated_game.results.should_not be_nil
    updated_game.results.length.should == 1
    result = updated_game.results[0]
    result.user_id.should == user.id
    result.type.should == 'SpeedArchetypeResult'
    result.score.should == {
      "speed_score" => "800",
      "average_time"=>"529",
      "average_time_simple"=>"340",
      "average_time_complex"=>"718",
      "fastest_time"=>"400",
      "slowest_time"=>"905",
      "description_id" => "10"
    }
    result.analysis_version.should == '2.0'
  end

  it 'persists the speed_archetype results when there are more than 3 results available' do
    user
    circadian = aggregate_result.scores["circadian"]
    aggregate_result.scores = {
      "simple" => {
                 "sums" => 3230.0,
        "total_results" => 4,
                 "mean" => 450.0,
                   "sd" => 2.0
      },
      "complex" => {
                 "sums" => 3000.0,
        "total_results" => 4,
                 "mean" => 530.0,
                   "sd" => 1.3
      },
      "circadian" => circadian }
    aggregate_result.save

    persist_rt = PersistSpeedArchetype.new    
    persist_rt.persist(game, @analysis_results)
    updated_game = Game.find(game.id)
    updated_game.results.should_not be_nil
    updated_game.results.length.should == 1
    result = updated_game.results[0]
    result.score.should == {
            "fastest_time" => "400",
            "slowest_time" => "905",
            "average_time" => "529",
             "speed_score" => "800",
     "average_time_simple" => "340",
    "average_time_complex" => "718",
          "description_id" => "3"
    }
  end

  it 'persists updates the high_scores' do 
    user
    game
    aggregate_result
    @analysis_results[:reaction_time2][:score][:speed_score] = 1800 

    persist_rt = PersistSpeedArchetype.new    
    persist_rt.persist(game, @analysis_results)

    result = AggregateResult.find_for_type(game.user_id, 'SpeedAggregateResult')
    result.high_scores.should_not be_nil
    result.all_time_best.should == 2400
    result.daily_best.should == 1800
    
  end


end