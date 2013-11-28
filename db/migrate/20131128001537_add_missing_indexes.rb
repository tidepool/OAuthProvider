class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :profile_descriptions, :display_id

    add_index :leaderboards, :user_id
    add_index :leaderboards, :game_name

    add_index :comments, :user_id
    add_index :comments, :activity_record_id

    add_index :highfives, :user_id
    add_index :highfives, :activity_record_id
  end
end
