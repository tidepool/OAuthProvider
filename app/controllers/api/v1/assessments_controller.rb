class Api::V1::AssessmentsController < Api::V1::ApiController
  doorkeeper_for :index, :show, :destroy, :update
  # doorkeeper_for :update, :if => lambda { Assessment.find(params[:id]).user_id != 0 }

  def index
    assessments = Assessment.includes(:definition).where('user_id = ?', target_user.id).order(:date_taken).all

    respond_to do |format|
      format.json { render :json => assessments, :each_serializer => AssessmentSummarySerializer }
    end
  end

  def show 
    assessment = current_resource
    
    respond_to do |format|
      format.json { render :json => assessment }
    end
  end

  def latest 
    assessment = current_resource
    respond_to do |format|
      format.json { render :json => assessment }
    end
  end

  def latest_with_profile
    assessment = current_resource
    respond_to do |format|
      format.json { render :json => assessment }
    end
  end

  def create
    definition = Definition.find_or_return_default(params[:def_id])
    assessment = Assessment.create_by_definition(definition, target_user)

    respond_to do |format|
      format.json { render :json => assessment}
    end
  end

  def update
    assessment = current_resource

    assessment.update_attributes(assessment_params)
    respond_to do |format|
      format.json { render :json => assessment}
    end
  end

  def destroy
    assessment = current_resource
    assessment.destroy
  end

  private

  def current_resource
    if params[:id]
      @current_resource ||= Assessment.includes(:definition, :result).find(params[:id])
    else
      resource_method = "find_#{params[:action]}".to_sym
      @current_resource ||= Assessment.send(resource_method, target_user) if Assessment.respond_to(resource_method)  
    end
  end

  def assessment_params
    params.require[:assessment].permit(:stage_completed, :status)  
  end
end
