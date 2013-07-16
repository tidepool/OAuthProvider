require 'spec_helper'

describe EmoResult do
  
  before(:each) do 
    @analysis_results = {:emo=>
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
          :emo_distances=>
           {:amused=>1.421512765416739,
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
            :triumph=>0.8568200008399066},
          :weakest_emotion=>
           {:emotion=>"amused", :distance_standard=>1.421512765416739},
          :strongest_emotion=>
           {:emotion=>"awe", :distance_standard=>0.3851313146973706}},
         {:emotion=>{:answer=>"sadness"}}],
       :score=>
        {:factors=>
          {:factor1=>41.66610693205314,
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
         :version=>"2.0"}}}
  end

  let(:user) { create(:user) }
  let(:game) { create(:game, user: user) }

  it 'correctly saves the result played and calculated times' do 
    result = EmoResult.create_from_analysis(game, @analysis_results)
    result.time_played.should_not be_nil
    result.time_calculated.should_not be_nil

    result = Result.where(game_id: game.id).first
    result.should_not be_nil        
  end

  it 'does not raise exception or create a result if reported_emotion does not exist'  do
    @analysis_results[:emo][:score].delete(:reported_emotion)
    result = EmoResult.create_from_analysis(game, @analysis_results)
    result.should be_nil

    result = Result.where(game_id: game.id).first
    result.should be_nil    
  end

  it 'does not raise exception or create a result if score does not exist'  do
    @analysis_results[:emo].delete(:score)
    result = EmoResult.create_from_analysis(game, @analysis_results)
    result.should be_nil

    result = Result.where(game_id: game.id).first
    result.should be_nil    
  end

  it 'does not raise exception or create a result if reported_emotion is not a known EmotionDescription'  do
    @analysis_results[:emo][:score][:reported_emotion] = "foobar"
    result = EmoResult.create_from_analysis(game, @analysis_results)
    result.should be_nil

    result = Result.where(game_id: game.id).first
    result.should be_nil    
  end

end
