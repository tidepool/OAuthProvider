require 'spec_helper'

describe PersistEmoIntelligence do
  let(:user) { create(:user) }
  let(:game) { create(:game, user: user) }

  before :each do
    @analysis_results = {
      :emo_intelligence => {
        :score_name=>"emo_intelligence",
        :final_results => [
          {
            :eq_score=>3840,
            :corrects=>7,
            :incorrects=>3,
            :instant_replays=>7,
            :time_elapsed=>2100
          }
        ],
        :score => {
          :eq_score=>3840,
          :corrects=>7,
          :incorrects=>3,
          :instant_replays=>7,
          :time_elapsed=>2100,
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
               "corrects" => "7",
               "eq_score" => "3840",
             "incorrects" => "3",
           "time_elapsed" => "2100",
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
  end

end