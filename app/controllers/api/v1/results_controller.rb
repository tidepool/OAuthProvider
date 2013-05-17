class Api::V1::ResultsController < Api::V1::ApiController
  doorkeeper_for :all, :unless => lambda { Assessment.find(params[:assessment_id]).user_id == 0 }
  respond_to :json

  def show
    assessment = Assessment.find(params[:assessment_id])
    if current_resource_owner && (current_resource_owner.admin? || current_resource_owner.id == assessment.user_id)
      status = :ok
      response_body = {}
      if assessment.status == :results_ready.to_s
        response_body = assessment.result
      else
        response_body = {
          :status => {
            :message => 'Results not calculated for this assessment'
          }
        }
        status = :not_found
      end
      respond_to do |format|
        format.json { render :json => response_body, :status => status}
      end
    else
      respond_with({}, status: :unauthorized)
    end
  end

  def create
    assessment = Assessment.find(params[:assessment_id])
    if current_resource_owner && (current_resource_owner.admin? || current_resource_owner.id == assessment.user_id)
      # Trigger the calculation in the backend
      ResultsCalculator.perform_async(assessment.id)
      respond_to do |format|
        response_body = {
          :status => {
            :state => :pending,
            :link => api_v1_assessment_progress_url,
            :message => 'Results are being calculated.'
          }
        }
        format.json { render :json => response_body, :status => :accepted }
      end
    else
      if current_resource_owner
        error_message = "User #{current_resource_owner.id} trying to access user #{assessment.user_id} assessment"
      else
        error_message = "No user logged in"
      end
      respond_to do |format|
        response_body = {
          :error => error_message
        }
        format.json { render :json => response_body, :status => :unauthorized }        
      end
    end

  end

  def progress
    assessment = Assessment.find(params[:assessment_id])
    if current_resource_owner && (current_resource_owner.admin? || current_resource_owner.id == assessment.user_id)
      http_status = :ok
      response_body = {}
      location = api_v1_assessment_progress_url
      if assessment.status == :results_ready.to_s
        response_body = {
          :status => {
            :state => :done,
            :link => api_v1_assessment_progress_url,
            :message => 'Results are ready.'
          }
        }
        location = api_v1_assessment_result_url
        http_status = :ok
      elsif assessment.status == :no_results.to_s
        response_body = {
          :status => {
            :state => :error,
            :link => api_v1_assessment_progress_url,
            :message => 'Error calculating results'
          }
        }
        http_status = :ok
      else
        response_body = {
          :status => {
            :state => :pending,
            :link => api_v1_assessment_progress_url,
            :message => 'Results are still being calculated'
          }
        }
        http_status = :ok
      end
      respond_to do |format|
        format.json { render :json => response_body, 
          :status => http_status, :location => location}
      end

    else
      respond_with({}, status: :unauthorized)
    end

  end

end
