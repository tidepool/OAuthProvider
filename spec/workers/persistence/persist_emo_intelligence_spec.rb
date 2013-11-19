require 'spec_helper'

describe PersistEmoIntelligence do
  let(:user) { create(:user) }
  let(:game) { create(:game, user: user, name: 'faceoff') }
  let(:emo_aggregate_result) { create(:emo_aggregate_result, user: user)}

  before :each do
    @analysis_results = {
      :emo_intelligence => {
        :score_name=>"emo_intelligence",
        :final_results => [
          {
            :emo_groups => {
              happy: { corrects: 2, incorrects: 2 },
              sad: { corrects: 2, incorrects: 1 },
              angry: { corrects: 1, incorrects: 0 }, 
              disgust: { corrects: 1, incorrects: 0 }, 
              fear: { corrects: 0, incorrects: 1 },
              surprise: {corrects: 0, incorrects: 0 }              
            },
            :eq_score=>3840,
            :corrects=>6,
            :incorrects=>4,
            :instant_replays=>7,
            :time_elapsed=>2100
          },
          {:emotion=>"sad"}
        ],
        :score => {
          :emo_groups => {
            happy: { corrects: 2, incorrects: 2 },
            sad: { corrects: 2, incorrects: 1 },
            angry: { corrects: 1, incorrects: 0 }, 
            disgust: { corrects: 1, incorrects: 0 }, 
            fear: { corrects: 0, incorrects: 1 },
            surprise: {corrects: 0, incorrects: 0 }              
          },
          :eq_score=>3840,
          :corrects=>6,
          :incorrects=>4,
          :instant_replays=>7,
          :time_elapsed=>2100,
          :reported_mood=>"sad",
          :version=>"2.0"
        },
        :timezone_offset=>7200
      }
    }
  end

  it 'persists the emo_intelligence result' do 
    user
    persist_rt = PersistEmoIntelligence.new
    persist_rt.persist(game, @analysis_results)

    updated_game = Game.find(game.id)
    updated_game.results.should_not be_nil
    updated_game.results.length.should == 1
    result = updated_game.results[0]
    result.user_id.should == user.id
    result.type.should == 'EmoIntelligenceResult'
    result.score.should == {
               "corrects" => "6",
               "eq_score" => "3840",
             "incorrects" => "4",
           "time_elapsed" => "2100",
           "reported_mood"=>"sad",
        "instant_replays" => "7"
    }
  end

  it 'persists the aggregate result, when there is none persisted yet' do 
    user
    persist_rt = PersistEmoIntelligence.new
    persist_rt.persist(game, @analysis_results)

    result = AggregateResult.find_for_type(game.user_id, 'EmoAggregateResult')
    result.should_not be_nil
    result.high_scores["daily_data_points"].should == "1"
    result.high_scores["daily_best"].should == "3840"
    result.high_scores["all_time_best"].should == "3840"

    result.scores.should == { 
      "sad" =>
        {
          "happy" => { "corrects" => 2, "incorrects" => 2 },
          "sad" => { "corrects" => 2, "incorrects" => 1 },
          "angry" => { "corrects" => 1, "incorrects" => 0 },
          "disgust" => { "corrects" => 1, "incorrects" => 0 },
          "fear" => { "corrects" => 0, "incorrects" => 1 },
          "surprise" => { "corrects" => 0, "incorrects" => 0 }
        }
    }
  end

  it 'persists the aggregate result, when there are others persisted before' do 
    user
    emo_aggregate_result
    @analysis_results[:emo_intelligence][:timezone_offset] = Time.zone.utc_offset
    persist_rt = PersistEmoIntelligence.new
    persist_rt.persist(game, @analysis_results)

    result = AggregateResult.find_for_type(game.user_id, 'EmoAggregateResult')
    result.should_not be_nil
    result.high_scores["daily_data_points"].should == "2"
    result.high_scores["daily_best"].should == "3840"
    result.high_scores["all_time_best"].should == "4000"
    result.high_scores["daily_average"].should == "1920"
    result.high_scores["last_value"].should == "3840"

    result.scores.should == {
      "sad" => 
        {
          "happy" => { "corrects" => 8, "incorrects" => 4 },
          "sad" => { "corrects" => 6, "incorrects" => 2 },
          "angry" => { "corrects" => 2, "incorrects" => 0 },
          "disgust" => { "corrects" => 2, "incorrects" => 2 },
          "fear" => { "corrects" => 3, "incorrects" => 2 },
          "surprise" => { "corrects" => 0, "incorrects" => 3 }
        }
    }
  end

  it 'persists the aggregate result for more than one mood in aggregates' do 
    user
    emo_aggregate_result
    @analysis_results[:emo_intelligence][:timezone_offset] = Time.zone.utc_offset
    @analysis_results[:emo_intelligence][:score][:reported_mood] = "angry"
    persist_rt = PersistEmoIntelligence.new
    persist_rt.persist(game, @analysis_results)

    result = AggregateResult.find_for_type(game.user_id, 'EmoAggregateResult')
    result.should_not be_nil
    result.scores.should == {
      "sad" => 
        {
          "happy" => { "corrects" => 6, "incorrects" => 2 },
          "sad" => { "corrects" => 4, "incorrects" => 1 },
          "angry" => { "corrects" => 1, "incorrects" => 0 },
          "disgust" => { "corrects" => 1, "incorrects" => 2 },
          "fear" => { "corrects" => 3, "incorrects" => 1 },
          "surprise" => { "corrects" => 0, "incorrects" => 3 }
        },
      "angry" =>
        {
          "happy" => { "corrects" => 2, "incorrects" => 2 },
          "sad" => { "corrects" => 2, "incorrects" => 1 },
          "angry" => { "corrects" => 1, "incorrects" => 0 },
          "disgust" => { "corrects" => 1, "incorrects" => 0 },
          "fear" => { "corrects" => 0, "incorrects" => 1 },
          "surprise" => { "corrects" => 0, "incorrects" => 0 }
        }
    }
  end

  it 'updates the leaderboard entries when a high score is reached' do 
    user
    emo_aggregate_result
    @analysis_results[:emo_intelligence][:score][:eq_score] = 5000
    persist_rt = PersistEmoIntelligence.new
    persist_rt.persist(game, @analysis_results)

    result = AggregateResult.find_for_type(game.user_id, 'EmoAggregateResult')
    result.should_not be_nil
    result.all_time_best.should == 5000

    lb_entry = Leaderboard.where(game_name: 'faceoff', user_id: user.id).first     
    lb_entry.score.should == 5000.0

    global_lb_entry = $redis.zscore "global_lb:faceoff", user.id.to_s
    global_lb_entry.should == 5000.0
  end

  it 'still updates the leaderboard when the game is played for the first time' do
    user

    result = AggregateResult.find_for_type(game.user_id, 'EmoAggregateResult')
    result.should be_nil

    @analysis_results[:emo_intelligence][:score][:eq_score] = 5000
    persist_rt = PersistEmoIntelligence.new
    persist_rt.persist(game, @analysis_results)

    result = AggregateResult.find_for_type(game.user_id, 'EmoAggregateResult')
    result.should_not be_nil
    result.all_time_best.should == 5000

    lb_entry = Leaderboard.where(game_name: 'faceoff', user_id: user.id).first     
    lb_entry.score.should == 5000.0

    global_lb_entry = $redis.zscore "global_lb:faceoff", user.id.to_s
    global_lb_entry.should == 5000.0  
  end

  it 'does not update the leaderboard if there is no high score' do 
    user
    emo_aggregate_result

    result = AggregateResult.find_for_type(game.user_id, 'EmoAggregateResult')
    result.should_not be_nil
    all_time_best = result.all_time_best

    @analysis_results[:emo_intelligence][:score][:eq_score] = 100
    persist_rt = PersistEmoIntelligence.new
    persist_rt.persist(game, @analysis_results)

    result = AggregateResult.find_for_type(game.user_id, 'EmoAggregateResult')
    result.should_not be_nil
    result.all_time_best.should == all_time_best

    lb_entry = Leaderboard.where(game_name: 'faceoff', user_id: user.id).first     
    lb_entry.score.should == all_time_best.to_f

    global_lb_entry = $redis.zscore "global_lb:faceoff", user.id.to_s
    global_lb_entry.should == all_time_best.to_f
  end
end