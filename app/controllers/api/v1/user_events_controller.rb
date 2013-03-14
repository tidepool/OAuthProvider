class Api::V1::UserEventsController < ApplicationController
  respond_to :json

  def create
    begin
      user_event = UserEvent.new(params[:user_event])
      user_event.record
      
      respond_with user_event
    rescue ArgumentError => error
      logger.info("#{error}")
      respond_with status: :bad_request
    end
  end
end
