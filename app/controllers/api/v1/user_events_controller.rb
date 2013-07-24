class Api::V1::UserEventsController < ApplicationController
  respond_to :json

  def create
    user_event = UserEvent.new(params[:user_event])
    user_event.record
    
    respond_to do |format|
      format.json { render :json => user_event }
    end
  end

  private
  def user_events_param
    params.require[:user_event].permit!
  end

end
