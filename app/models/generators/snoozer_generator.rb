class SnoozerGenerator < BaseGenerator
  def initialize(user)
    @average_speed_score = calculate_recent_average(user.id)
  end

  def generate(stage_no, stage_template)
    stage_template
  end

  def calculate_recent_average(user_id)
    return 0 if user_id.nil?

    recent_games = SpeedArchetypeResult.where(user_id: user_id).order('time_played DESC').limit(5)
    count = recent_games.length
    average_speed_score = recent_games.reduce(0) { |sum, game| sum + game.speed_score.to_i }
    average_speed_score = count > 0 ? average_speed_score / count : 0
  end
end