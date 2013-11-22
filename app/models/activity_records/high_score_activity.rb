class HighScoreActivity < ActivityRecord

  def self.create_from_rawdata(user, raw_data)
    activity = user.activity_records.build(:type => 'HighScoreActivity')
    activity.record_usuals(raw_data)
    activity.save!
    activity
  end

  def description 
    user_id_url = "tidepool://user/#{self.user.id}"
    score = self.raw_data["score"]
    game_name = self.raw_data["game_name"]
    game_name_url = "tidepool://game/#{game_name}"
    "[#{self.user.name}](#{user_id_url}) scored a new highscore, #{score} in [#{game_name}](#{game_name_url})"
  end

  def target 
    :send_all_friends
  end
end