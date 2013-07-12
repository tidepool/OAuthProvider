require 'spec_helper'

describe 'Recommendations API' do 
  include AppConnections

  def create_emotion_result
    analysis_results = {:emo=>
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

       persist_emo = PersistEmo.new
       persist_emo.persist(game, analysis_results)

       updated_game = Game.find(game.id)
       updated_game.results.length.should == 1
       result = updated_game.results[0]
  end

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:personality) { create(:personality, profile_description_id: 3) }
  let(:user1) { create(:user, personality: personality) }
  let(:user2) { create(:user) }
  let(:game) { create(:game, user: user1) }

  it 'gets a random recommendation for a given big5_dimension for user' do
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/recommendations/latest.json")
    response.status.should == 200        
    reco_result = JSON.parse(response.body, symbolize_names: true)
    reco_result[:big5_dimension].should == "high_openness"
    reco_result[:sentence].should_not be_nil
    reco_result[:link_title].should_not be_nil
    reco_result[:link].should_not be_nil
    reco_result[:link_type].should_not be_nil
    reco_result[:icon_url].should_not be_nil
  end

  it 'gets a career recommendation for a given user' do
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/recommendations/career.json")
    response.status.should == 200
    reco_result = JSON.parse(response.body, symbolize_names: true)
    reco_result[:careers].length.should == 4
    reco_result[:careers][3].should == "Life coach"
    reco_result[:tools].length.should == 3
    reco_result[:tools][0].should == "Analytic and scientific software"
    reco_result[:skills].length.should == 2
    reco_result[:skills][1].should == "General psychology training"
  end

  it 'gets an emotion description and recommendation for a given result' do
    token = get_conn(user1)
    result = create_emotion_result

    response = token.get("#{@endpoint}/users/-/recommendations/emotion.json?emo_result_id=#{result.id}")
    response.status.should == 200
    reco_result = JSON.parse(response.body, symbolize_names: true)
    reco_result[:emotion].should == 'awe'
    reco_result[:friendly_name].should_not be_nil
  end

  it 'gets actions for only recommended items and not games' do 
    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/recommendations/actions.json")
    response.status.should == 200
    reco_result = JSON.parse(response.body, symbolize_names: true)
    reco_result.length.should == 4
  end

end