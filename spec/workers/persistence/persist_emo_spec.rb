require 'spec_helper'

describe PersistBig5 do
  let(:user) { create(:user) }
  let(:game) { create(:game, user: user) }


  before(:all) do 
    @analysis_results = {
      :emo=>
        {:final_results=>
          [{:factors=>
             {:factor4=>
               {:weighted_total=>4.56603035401403,
                :count=>5,
                :mean=>1.148849,
                :std=>0.704299,
                :average=>0.913206070802806,
                :average_zscore=>-0.3345779692959865},
              :factor3=>
               {:weighted_total=>2.576906709508851,
                :count=>4,
                :mean=>0.897779,
                :std=>0.591149,
                :average=>0.6442266773772127,
                :average_zscore=>-0.42891440672789305},
              :factor1=>
               {:weighted_total=>5.298968670152882,
                :count=>7,
                :mean=>1.496121,
                :std=>0.886891,
                :average=>0.7569955243075546,
                :average_zscore=>-0.8333893067946856},
              :factor5=>
               {:weighted_total=>2.127586737374739,
                :count=>2,
                :mean=>1.377737,
                :std=>0.919911,
                :average=>1.0637933686873695,
                :average_zscore=>-0.34127609226613276},
              :factor2=>
               {:weighted_total=>3.1809420821949725,
                :count=>4,
                :mean=>1.155778,
                :std=>0.710837,
                :average=>0.7952355205487431,
                :average_zscore=>-0.5072083747065176}},
            :flagged_result1=>false,
            :weakest_emotion=>
             {:emotion=>"amused", :distance_standard=>1.421512765416739},
            :strongest_emotion=>
             {:emotion=>"awe", :distance_standard=>0.3851313146973706}}],
         :score=>
          {:factors=>
            {:factor1=>41.66610693205314,
             :factor2=>44.92791625293482,
             :factor3=>45.71085593272107,
             :factor4=>46.654220307040134,
             :factor5=>46.58723907733867},
           :flagged_result1=>false,
           :weakest_emotion=>
            {:emotion=>"amused", :distance_standard=>1.421512765416739},
           :strongest_emotion=>
            {:emotion=>"awe", :distance_standard=>0.3851313146973706}},
         :version=>"2.0"}
       }  
  end

  it 'persists the emo results' do 
    persist_emo = PersistEmo.new
    persist_emo.persist(game, @analysis_results)
    
    updated_game = Game.find(game.id)
    updated_game.results.length.should == 1
    result = updated_game.results[0]
    result.should_not be_nil
    result.factor1.should == "41.66610693205314"
    result.factor2.should == "44.92791625293482"
    result.factor3.should == "45.71085593272107"
    result.factor4.should == "46.654220307040134"
    result.factor5.should == "46.58723907733867"
    result.strongest_emotion.should == "awe"
    result.weakest_emotion.should == "amused"
    result.flagged_result1 == "false"
    result.display_emotion_name = "awe"
    result.display_emotion_friendly.should_not be_nil
  end

end
