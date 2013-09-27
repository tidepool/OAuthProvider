class Api::V1::FitbitNotificationsController < Api::V1::ApiController
  def notify
    updates = param[:updates]
    TrackerDispatcher.perform_async(0, 'fitbit', updates)
    respond_to do |format|
      format.all { head :no_content }
    end
  end
end
