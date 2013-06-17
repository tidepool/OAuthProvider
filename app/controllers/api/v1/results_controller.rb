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
        status: {
          state: :error,
          message: 'Results not calculated for this game.'
        }
      }
      status = :not_found
    end
    respond_to do |format|
      format.json { render :json => response_body, :status => status}
    end
  end

  def create
    result_response = determine_result_response

    if result_response[:header][:http_status] == :accepted
      # Change the state of the game to :calculating_results
      current_resource.status = :calculating_results
      current_resource.save

      # Trigger the calculation in the backend
      ResultsCalculator.perform_async(current_resource.id)
    end

    respond_to do |format|
      format.json { render :json => result_response[:body], :status => result_response[:header][:http_status] }
    end
  end

  def progress
    result_response = determine_result_response

    respond_to do |format|
      format.json { render :json => result_response[:body], 
        :status => result_response[:header][:http_status], :location => result_response[:header][:location]}
    end
  end

  protected

  def determine_result_response
    status = current_resource && current_resource.status.to_sym
    result_response = {}    
    case status
    # when :not_started
    #   # This is an error we need to first start the game
    #   result_response = {
    #     body: {
    #       status: {
    #         state: :error,
    #         message: 'Game has not been started, results can not be calculated'
    #       }
    #     },
    #     header: {
    #       http_status: :precondition_failed,
    #       location: ''
    #     }
    #   }
    when :completed, :in_progress, :not_started
      # TODO: We need to enforce that game is not in-progress state
      # We will change this later. For now we are treating :in_progress same as
      # :completed
      result_url = api_v1_user_game_progress_url
      result_response = {
        body: {
          status: {
            state: :pending,
            link: result_url,
            message: 'Starting to calculate results.'
          }
        },
        header: {
          http_status: :accepted,
          location: result_url
        }
      }
    when :calculating_results
      result_url = api_v1_user_game_progress_url
      result_response = {
        body: {
          status: {
            state: :pending,
            link: result_url,
            message: 'Results are still being calculated.'
          }
        },
        header: {
          http_status: :ok,
          location: result_url
        }
      }
    when :results_ready      
      result_url = result_url(current_resource)
      result_response = {
        body: {
          status: {
            state: :done,
            link: result_url,
            message: 'Results are ready.'
          }
        },
        header: {
          http_status: :ok,
          location: result_url
        }
      }
    when :no_results
      result_url = api_v1_user_game_result_url
      result_response = {
        body: {
          status: {
            state: :error,
            link: result_url,
            message: 'Error calculating results.'
          }
        },
        header: {
          http_status: :ok,
          location: result_url
        }
      }
    else
      logger.error("Game #{params[:game_id]} does not exist or unknown status.")
      result_response = {
        body: {
          status: {
            state: :error,
            message: 'Game does not exist, or in unknown status'
          }
        },
        header: {
          http_status: :bad_request,
          location: ''
        }
      }
    end
    result_response
  end

  def result_url(resource)
    if current_resource.calculates_personality?
      result_url = api_v1_user_personality_url
    else
      result_url = api_v1_user_game_result_url
    end
    result_url
  end  

  def current_resource 
    @game ||= Game.find(params[:game_id]) if params[:game_id]
  end
end