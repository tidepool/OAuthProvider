class Api::V1::FitbitNotificationsController < Api::V1::ApiController
  def notify
    uploaded_file = params[:updates]
    updates = nil
    if uploaded_file.respond_to?(:read)
      updates = uploaded_file.read 
    end
    TrackerDispatcher.perform_async(0, 'fitbit', updates)
    respond_to do |format|
      format.all { head :no_content }
    end
  end

  def authorize
    true
  end
end

