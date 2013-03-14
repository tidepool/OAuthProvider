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
    if @assessment.user != current_resource_owner
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
    @assessment = Assessment.create_with_definition_and_user(definition, current_resource_owner)
    # respond_with @assessment

    respond_to do |format|
      format.json { render :json => @assessment}
    end
  end

  def update
    @assessment = Assessment.find(params[:id])

    attributes = params[:assessment]
    if attributes[:status] == 'completed' 
      # Trigger the calculation in the backend
      event_data = { assessment_id: @assessment.id } 
      $redis.publish(ACTION_EVENT_QUEUE, event_data.to_json)
    end

    @assessment.update_attributes(attributes)
    respond_with @assessment 
  end

end
