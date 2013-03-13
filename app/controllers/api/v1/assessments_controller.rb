class Api::V1::AssessmentsController < ApplicationController
  respond_to :json

  def index
    if !current_user || current_user.guest
      respond_to do |format|
        format.json { render :json => {}, :status => :unauthorized }
      end
    end
    @assessments = Assessment.includes(:definition).where('user_id = ?', current_user.id).order(:date_taken).all

    respond_to do |format|
      format.json { render :json => @assessments, :each_serializer => AssessmentSummarySerializer }
    end
  end

  def show 
    @assessment = Assessment.find(params[:id])
    if @assessment.user != current_user
      respond_to do |format|
        format.json { render :json => {}, :status => :unauthorized }
      end
    else
      if params[:results]
        if @assessment.results_ready?
          respond_to do |format|
            format.json { render :json => @assessment}
          end
        else
          respond_to do |format|
            format.json { render :json => {}, :status => :partial_content}
          end
        end
      else
        respond_with @assessment
      end
    end
  end

  def create
    definition = Definition.find_or_return_default(params[:def_id])
    @assessment = Assessment.create_with_definition_and_user(definition, current_user)
    respond_with @assessment
  end

  def update
    @assessment = Assessment.find(params[:id])

    respond_to do |format|
      if @assessment.update_attributes(params[:assessment])
        format.json { render :json => {}, :status => :accepted}
      else
        format.json { render :json => {}, :status => :unprocessable_entity }

      end
    end
  end

end
