require 'pry' if Rails.env.test? || Rails.env.development?

class Api::V1::AssessmentsController < Api::V1::ApiController
  doorkeeper_for :all, :except => :create
  respond_to :json
  ACTION_EVENT_QUEUE = 'action_events'

  def index
    if !current_resource_owner
      respond_with({}, status: :unauthorized)
    end
    @assessments = Assessment.includes(:definition).where('user_id = ?', current_resource_owner.id).order(:date_taken).all

    respond_to do |format|
      format.json { render :json => @assessments, :each_serializer => AssessmentSummarySerializer }
    end
  end

  def show 
    @assessment = Assessment.find(params[:id])
    if @assessment.user != current_resource_owner || !current_resource_owner.admin?
      respond_to do |format|
        format.json { render :json => {}, :status => :unauthorized }
      end
    else
      respond_with @assessment
    end
  end

  def create
    user = params[:user_id].nil? ? current_resource_owner : User.where('id = ?', params[:user_id]).first

    definition = Definition.find_or_return_default(params[:def_id])
    @assessment = Assessment.create_or_find(definition, current_resource_owner, user)
    # respond_with @assessment

    respond_to do |format|
      format.json { render :json => @assessment}
    end
  end

  def update
    @assessment = Assessment.find(params[:id])
    attributes = params[:assessment]

    @assessment.update_attributes_with_caller(attributes, current_resource_owner)
    # binding.pry
    # respond_with @assessment 
    respond_to do |format|
      format.json { render :json => @assessment}
    end

  end

end
