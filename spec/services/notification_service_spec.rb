require 'spec_helper'

describe NotificationService do
  include NotificationHelpers

  let(:user1) { create(:user, name: 'John Doe') }

  it 'adds a new notification' do 
    not_service = NotificationService.new
    notification = {
      alert: "John is now friends with Mary."
    }
    not_service.add_notification(user1.id, notification)

    notification_entries = $redis.zrevrange "notifications:#{user1.id}", 0, 1
    notification_count = $redis.get "unread_notifications_count:#{user1.id}"
    notification_entries.should_not be_empty
    notification_entries[0].should == notification.to_json
    notification_count.should == "1"
  end

  it 'lists the existing notifications' do 
    time = Time.zone.now - 1.days
    nots = create_notifications(user1.id, "John")
    not_service = NotificationService.new
    notifications, api_status = not_service.list_notifications(user1.id) 
    notifications.length.should == nots.length
    notifications.each_with_index do | notification, i |
      notification[:message].should == nots[nots.length - i - 1][:alert]
      notification[:is_read].should == false
    end
  end

  it 'lists a mix of read and unread notifications' do 
    time = Time.zone.now - 1.days
    nots = create_notifications(user1.id, "John", time)
    not_service = NotificationService.new
    not_service.clear_notifications(user1.id, time + 1.hours)
    nots = create_notifications(user1.id, "Joe")
    notifications, api_status = not_service.list_notifications(user1.id)    
    notifications.length.should == nots.length * 2
    notifications.each_with_index do | notification, i |
      if i < nots.length
        notification[:is_read].should == false
      else
        notification[:is_read].should == true
      end
    end
  end

  it 'clears the notifications' do 
    time = Time.zone.now - 1.days
    nots = create_notifications(user1.id, "John", time)
    not_service = NotificationService.new
    not_service.clear_notifications(user1.id, time + 1.hours)

    unread_count = $redis.get "unread_notifications_count:#{user1.id}"
    reset_time = $redis.get "unread_reset_time:#{user1.id}"

    reset_time.to_i.should == (time + 1.hours).to_i
    unread_count.should == "0"    
  end
end