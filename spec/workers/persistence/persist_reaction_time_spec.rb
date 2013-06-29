require 'spec_helper'

describe PersistReactionTime do
  let(:user) { create(:user) }
  let(:game) { create(:game, user: user) }

  before(:all) do 
    @analysis_results = {
      reaction_time: {
        score: {
          fastest_time: 455,
          slowest_time: 600, 
          average_time: 520
        },
        final_results: [
          {
            total_average_time_zscore: -3.2,
            total_average_time: 1055,
            average_time: 520,
            min_time: 455,
            max_time: 600
          },
          {
            demand: 50
          }
        ]
      }
    }
  end

  it 'persists the reaction_time results' do 
    persist_rt = PersistReactionTime.new
    persist_rt.persist(game, @analysis_results)
    game.results.should_not be_nil
    game.results.length.should == 1
    result = game.results[0]
    result.result_type.should == 'reaction_time'
    result.score.should == {
      "fastest_time" => "455",
      "slowest_time" => "600", 
      "average_time" => "520"      
    }
  end

  it 'has the demand calculation in the final results' do 
    persist_rt = PersistReactionTime.new
    persist_rt.persist(game, @analysis_results)
    game.results.should_not be_nil
    result = game.results[0]
    result.calculations["final_results"].should_not be_nil
    result.calculations["final_results"].length.should == 2
    result.calculations["final_results"][0]["total_average_time_zscore"].should == -3.2
    result.calculations["final_results"][0]["total_average_time"].should == 1055
    result.calculations["final_results"][0]["average_time"].should == 520
    result.calculations["final_results"][0]["min_time"].should == 455
    result.calculations["final_results"][0]["max_time"].should == 600

    result.calculations["final_results"][1]["demand"].should == 50
  end

  it 'updates the user stats with the fastest and slowest times first time' do
    persist_rt = PersistReactionTime.new
    persist_rt.persist(game, @analysis_results)

    updated_user = User.find(user.id)
    updated_user.stats.should_not be_nil
    updated_user.stats.should == {
      "fastest_time" => "455",
      "slowest_time" => "600"
    }
  end

  it 'updates the user stats with the fastest and slowest if it is the fastest or slowest ever' do 
    user.stats = {
      "fastest_time" => "465",
      "slowest_time" => "590"      
    }
    user.save!
    persist_rt = PersistReactionTime.new
    binding.pry
    persist_rt.persist(game, @analysis_results)

    updated_user = User.find(user.id)
    updated_user.stats.should == {
      "fastest_time" => "455",
      "slowest_time" => "600"
    }    
  end

  it 'does not update the user stats with the fastest and slowest if it is not the fastest or slowest ever' do
    user.stats = {
      "fastest_time" => "435",
      "slowest_time" => "610"      
    }
    user.save!
    persist_rt = PersistReactionTime.new
    persist_rt.persist(game, @analysis_results)

    updated_user = User.find(user.id)
    updated_user.stats.should == {
      "fastest_time" => "435",
      "slowest_time" => "610"
    }    
  end
end

