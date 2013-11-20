class HighScoreActivity < ActivityRecord

  def self.create_from_rawdata(user, raw_data)
    activity = user.activity_records.build(:type => 'HighScoreActivity')
    activity.record_usuals(raw_data)
    activity.save!
    activity
  end

  def description 
    score = self.raw_data["score"]
    game_name = self.raw_data["game_name"]
    "@#{self.user.name} scored a new highscore, #{score} in #{game_name}"
  end

  def target 
    :friends
  end
end