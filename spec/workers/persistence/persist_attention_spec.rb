require 'spec_helper'

describe PersistAttention do
  let(:user) { create(:user) }
  let(:game) { create(:game, user: user, name: 'echo') }
  let(:attention_aggregate_result) { create(:attention_aggregate_result, user: user)}

  before :each do
    @analysis_results = {
      :attention => {
        :score_name => "attention",
        :final_results => [
          {
            :attention_score=>2100,
            :stage_scores=>
              [ {:highest=>5, :score=>500}, {:highest=>8, :score=>1600} ]
          }
        ],
        :score => { 
          :attention_score=>2100,
          :stage_scores=>
            [ {:highest=>5, :score=>500}, {:highest=>8, :score=>1600} ],
          :version=>"2.0"
        },
        :timezone_offset=>-28800
      }
    }
  end

  it 'persists the attention result' do 
    user
    persist_rt = PersistAttention.new
    persist_rt.persist(game, @analysis_results)

    updated_game = Game.find(game.id)
    updated_game.results.should_not be_nil
    updated_game.results.length.should == 1
    result = updated_game.results[0]
    result.user_id.should == user.id
    result.type.should == 'AttentionResult'
    result.attention_score.should == "2100"
    result.calculations.should == {
      "stage_scores" => [
        {
          "highest" => 5,
          "score" => 500
        },
        {
          "highest" => 8,
          "score" => 1600
        }
      ]
    }    
  end

  it 'persists the aggregate result, when there is none persisted yet' do 
    user
    persist_rt = PersistAttention.new
    persist_rt.persist(game, @analysis_results)

    result = AggregateResult.find_for_type(game.user_id, 'AttentionAggregateResult')
    result.should_not be_nil
    result.high_scores["daily_data_points"].should == "1"
    result.high_scores["daily_best"].should == "2100"
    result.high_scores["all_time_best"].should == "2100"

    current_time = Time.zone.now
    result.scores["circadian"][current_time.hour.to_s].should == {
      "score" => 2100,
      "times_played" => 1
    }

    result.scores["weekly"][current_time.wday].should == {
      "score" => 2100,
      "average_score" => 2100,
      "data_points" => 1
    } 
  end

  it 'persists the aggregate result, when there are others persisted before' do 
    user
    attention_aggregate_result
    current_time = Time.zone.now
    prior_circadian = attention_aggregate_result.scores["circadian"][current_time.hour.to_s]
    prior_weekly = attention_aggregate_result.scores["weekly"][current_time.wday]

    @analysis_results[:attention][:timezone_offset] = Time.zone.utc_offset
    persist_rt = PersistAttention.new
    persist_rt.persist(game, @analysis_results)

    result = AggregateResult.find_for_type(game.user_id, 'AttentionAggregateResult')
    result.should_not be_nil
    result.high_scores["daily_data_points"].should == "2"
    result.high_scores["daily_best"].should == "2100"
    result.high_scores["all_time_best"].should == "2500"
    result.high_scores["daily_average"].should == "1050"
    result.high_scores["last_value"].should == "2100"

    expected_score = prior_circadian["score"].to_i > 2100 ? prior_circadian["score"].to_i : 2100
    expected_frequency =  prior_circadian["times_played"].to_i + 1
    result.scores["circadian"][current_time.hour.to_s].should == {
      "score" => expected_score,
      "times_played" => expected_frequency
    }

    expected_score = prior_weekly["score"].to_i > 2100 ? prior_weekly["score"].to_i : 2100
    expected_frequency = prior_weekly["data_points"].to_i + 1
    result.scores["weekly"][current_time.wday].should == {
      "score" => expected_score,
      "average_score" => 1050,
      "data_points" => expected_frequency
    } 
  end

  it 'persists the aggregate result with correct timezone settings' do 
    user
    @analysis_results[:attention][:timezone_offset] = 7200

    persist_rt = PersistAttention.new
    persist_rt.persist(game, @analysis_results)

    result = AggregateResult.find_for_type(game.user_id, 'AttentionAggregateResult')

    current_time = Time.zone.now.in_time_zone(7200/60/60)
    result.scores["circadian"][current_time.hour.to_s].should == {
      "score" => 2100,
      "times_played" => 1
    }

    result.scores["weekly"][current_time.wday].should == {
      "score" => 2100,
      "average_score" => 2100,
      "data_points" => 1
    } 
  end

  it 'updates the leaderboard entries when a high score is reached' do 
    user
    attention_aggregate_result
    @analysis_results[:attention][:score][:attention_score] = 5000

    persist_rt = PersistAttention.new
    persist_rt.persist(game, @analysis_results)

    result = AggregateResult.find_for_type(game.user_id, 'AttentionAggregateResult')
    result.should_not be_nil
    result.all_time_best.should == 5000

    lb_entry = Leaderboard.where(game_name: 'echo', user_id: user.id).first     
    lb_entry.score.should == 5000.0

    global_lb_entry = $redis.zscore "global_lb:echo", user.id.to_s
    global_lb_entry.should == 5000.0
  end

end