require 'spec_helper'

describe 'Notifications API' do 
  include AppConnections
  include NotificationHelpers

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:user1) { create(:friend_user, name: 'John Doe') }

  it 'gets a list of notifications for a user' do 
    time = Time.zone.now - 1.days
    nots = create_notifications(user1.id, "John", time)

    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/notifications.json")
    result = JSON.parse(response.body, symbolize_names: true)
    notifications = result[:data]
    notifications.length.should == 3
    notifications.each_with_index do |notification, i| 
      notification[:message].should == nots[nots.length - i - 1][:alert]
      notification[:is_read].should == false
    end

    status = result[:status]
    status.should == {
        :offset => 0,
        :limit => 20,
        :next_offset => 0,
        :next_limit => 20,
        :total => 3      
    }
  end

  it 'clears the notifications for a user' do 
    time = Time.zone.now - 1.days
    nots = create_notifications(user1.id, "John", time)

    token = get_conn(user1)
    response = token.post("#{@endpoint}/users/-/notifications/clear.json")
    result = JSON.parse(response.body, symbolize_names: true)
    response.status.should == 200

    unread_count = $redis.get "unread_notifications_count:#{user1.id}"
    reset_time = $redis.get "unread_reset_time:#{user1.id}"
    reset_time.to_i.should_not be_nil
    unread_count.should == "0"    

    response = token.get("#{@endpoint}/users/-/notifications.json")
    result = JSON.parse(response.body, symbolize_names: true)
    notifications = result[:data]
    notifications.length.should == 3
    notifications.each_with_index do |notification, i| 
      notification[:is_read].should == true
    end
  end
end