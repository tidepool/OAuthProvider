module NotificationHelpers  
  def create_notifications(user_id, name, time=Time.zone.now)
    notifications = [
      {
        alert: "#{name} is now friends with Mary."
      },
      {
        alert: "Mary commented on #{name} new highscore."
      },
      {
        alert: "Mary liked #{name} new highscore."
      }
    ]

    not_service = NotificationService.new
    notifications.each do |notification|
      not_service.add_notification(user_id, notification, time)
      time = time + 10.seconds
    end
    notifications
  end
end
