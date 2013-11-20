class MakeFriendsActivity < ActivityRecord

  def self.create_from_rawdata(user, raw_data)
    activity = user.activity_records.build(:type => 'MakeFriendsActivity')
    activity.record_usuals(raw_data)
    activity.save!
    activity
  end

  def description
    friend_name = self.raw_data["friend_name"]
    "@#{self.user.name} is now friends with @#{friend_name}"
  end

  def target
    :friends
  end
end