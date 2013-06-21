class Api::V1::RecommendationsController < Api::V1::ApiController
  doorkeeper_for :latest

  def latest
    personality = current_resource.personality
    random_generator = Random.new
    rec_no = random_generator.rand(0...5)
    recommendation = Recommendation.where('big5_dimension = ?', personality.big5_dimension).limit(1).offset(rec_no).first

    respond_to do |format|
      format.json { render :json => recommendation }
    end
  end

  private 

  def current_resource
    target_user
  end

end