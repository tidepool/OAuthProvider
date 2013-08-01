class SocialGame < ActiveRecord::Base
  serialize :participants_status, JSON

  has_many    :games
  belongs_to  :social_game_definition
  belongs_to  :game

  def self.create_by_definition(definition, host_user, calling_ip = nil)
    raise ArgumentError, 'No definition specified' if definition.nil?
    raise ArgumentError, 'Requires a target user' if host_user.nil?   
   
    create! do |game|
      game.social_game_definition = definition
      game.host_user = host_user
      game.participants_expected = 1  # At least the host user when created first
      game.calling_ip = calling_ip
      game.date_taken = Time.zone.now
    end
  end
end
