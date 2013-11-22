class MakeFriendsActivity < ActivityRecord

  def self.create_from_rawdata(user, raw_data)
    activity = user.activity_records.build(:type => 'MakeFriendsActivity')
    activity.record_usuals(raw_data)
    activity.save!
    activity
  end

  def description
    user_id_url = "tidepool://user/#{self.user.id}"
    friend_name = self.raw_data["friend_name"]
    friend_id_url = "tidepool://user/#{self.raw_data['friend_id']}"
    "[#{self.user.name}](#{user_id_url}) is now friends with [#{friend_name}](#{friend_id_url})"
  end

  def target
    :send_all_friends
  end
end