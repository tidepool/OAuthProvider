module ActivityStreamHelpers
  def create_activity(user_id, activities)
    activity_stream = ActivityStreamService.new

    activities = Array(activities)
    activities.each do |activity|
      activity_stream.register_activity(user_id, activity)
    end
  end

end