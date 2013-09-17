require 'spec_helper'

describe PersistSpeedArchetype do
  let(:user) { create(:user) }
  let(:game) { create(:game, user: user) }
  let(:personality) { create(:personality, user: user) }
  let(:aggregate_result) { create(:aggregate_result, user: user) }
  let(:game2) { create(:game, user: user) }
  let(:speed_archetype_result) { create(:speed_archetype_result, game: game2)}
  let(:prior_speed_archetypes) { create_list(:prior_speed_archetypes, 10, game: game2, user:user)}

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

  it 'persists the speed_archetype results when no results available' do 
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

    result = AggregateResult.find_for_type(game.user_id, 'SpeedAggregateResult')
    result.should_not be_nil
    result.scores['weekly'][Time.zone.now.wday].should == {
      "speed_score" => 800,
      "fastest_time" => 400,
      "slowest_time" => 905,
       "data_points" => 1
    }    
  end

  it 'persists the speed_aggregate_result with the correct weekly results' do
    user
    circadian = aggregate_result.scores["circadian"]
    weekly = []
    (0..6).each do |i|
      if i == Time.zone.now.wday 
        weekly << {
         'speed_score' => 1200,
         'fastest_time' => 300,
         'slowest_time' => 800,
         'data_points' => 1         
        }
      else
        weekly << {
          'speed_score' => 0,
          'fastest_time' => 1000000,
          'slowest_time' => 0,
          'data_points' => 0
        }
      end
    end
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
          "circadian" => circadian,
          "weekly" => weekly }
    aggregate_result.save
        
    persist_rt = PersistSpeedArchetype.new  
    persist_rt.persist(game, @analysis_results)

    result = AggregateResult.find_for_type(game.user_id, 'SpeedAggregateResult')
    result.should_not be_nil
    result.scores['weekly'][Time.zone.now.wday].should == {
      "speed_score" => 1200,
      "fastest_time" => 300,
      "slowest_time" => 905,
      "data_points" => 2
    }        
  end

  it 'persists the speed_aggregate_result for users who already have played snoozer games' do 
    # This is for the TidePool launch users.
    # They will have:
    # * multiple SpeedArchetypeResults
    # * one SpeedAggregateResult but no weekly in it.

    user
    prior_speed_archetypes
    aggregate_result

    persist_rt = PersistSpeedArchetype.new    
    persist_rt.persist(game2, @analysis_results)

    result = AggregateResult.find_for_type(game2.user_id, 'SpeedAggregateResult')
    result.should_not be_nil
    result.scores['weekly'].should_not be_nil
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

  it 'returns fast if the the game already has the personality persisted' do 
    game2
    speed_archetype_result
    persist_rt = PersistSpeedArchetype.new
    persist_rt.persist(game2, @analysis_results)
    updated_game = Game.find(game2.id)
    updated_game.results.length.should == 1
    updated_game.results[0].id.should == speed_archetype_result.id
  end

end