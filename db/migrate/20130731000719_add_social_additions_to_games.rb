class AddSocialAdditionsToGames < ActiveRecord::Migration
  def change
    add_column :games, :social_game_id, :integer
    add_column :games, :user_assets, :text
  end
end
