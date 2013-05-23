class Api::V1::ResultsController < Api::V1::ApiController
  doorkeeper_for :all
  respond_to :json

  def show
    status = :ok
    response_body = {}
    if current_resource.status == :results_ready.to_s
      response_body = current_resource.result
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
  end

  def create
    # Trigger the calculation in the backend
    ResultsCalculator.perform_async(current_resource.id)
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

    respond_to do |format|
      response_body = {
        :error => error_message
      }
      format.json { render :json => response_body, :status => :unauthorized }        
    end
  end

  def progress
    http_status = :ok
    response_body = {}
    location = api_v1_assessment_progress_url
    if current_resource.status == :results_ready.to_s
      response_body = {
        :status => {
          :state => :done,
          :link => api_v1_assessment_progress_url,
          :message => 'Results are ready.'
        }
      }
      location = api_v1_assessment_result_url
      http_status = :ok
    elsif current_resource.status == :no_results.to_s
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
  end

  protected

  def current_resource 
    @assessment ||= Assessment.find(params[:assessment_id]) if params[:assessment_id]
  end
end
