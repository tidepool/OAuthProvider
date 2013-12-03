module ActivityStreamHelpers
  def create_activity(user_id, activities)
    activity_stream = ActivityStreamService.new

    activities = Array(activities)
    activities.each do |activity|
      activity_stream.register_activity(user_id, activity)
    end
  end

  def create_highfives(user_id, activities)
    activities.each_with_index do | activity, i |
      unless i == 2
        num_highfives = Random.new.rand(7)
        (0...num_highfives).each do |i|
          highfive = activity.highfives.build
          highfive.user_id = user_id
          highfive.save!
        end 
      end
    end
  end
end