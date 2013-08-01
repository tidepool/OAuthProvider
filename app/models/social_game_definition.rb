class SocialGameDefinition < ActiveRecord::Base
  store_accessor :game_definitions, :host_game_name, :participant_game_name

end
