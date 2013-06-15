class RenameColumnsInPersonality < ActiveRecord::Migration
  def change
    rename_column :personalities, :user, :user_id
    rename_column :personalities, :profile_description, :profile_description_id
    rename_column :personalities, :game, :game_id
  end
end
