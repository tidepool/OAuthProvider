class Api::V1::RecommendationsController < Api::V1::ApiController
  doorkeeper_for :all

  def latest
    personality = current_resource.personality
    random_generator = Random.new
    rec_no = random_generator.rand(0...5)
    recommendation = Recommendation.where('big5_dimension = ?', personality.big5_dimension).limit(1).offset(rec_no).first

    respond_to do |format|
      format.json { render :json => recommendation }
    end
  end

  def career
    profile_description_id = current_resource.personality.profile_description_id
    career_reco = CareerRecommendation.where(profile_description_id: profile_description_id).first

    respond_to do |format|
      format.json { render :json => career_reco }
    end
  end

  def emotion
    emotion_result = Result.find(params[:emo_result_id])
    emotion_reco = EmoRecommendation.new(emotion_result)
    

    respond_to do |format|
      format.json { render :json => emotion_reco.recommendation }
    end
  end

  def actions
    builder = RecommendationBuilder.new(target_user)

    respond_to do |format|
      format.json { render :json => builder.recommendations }
    end    
  end

  private 

  def current_resource
    target_user
  end
end