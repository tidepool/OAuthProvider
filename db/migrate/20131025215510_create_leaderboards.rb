class CreateLeaderboards < ActiveRecord::Migration
  def change
    create_table :leaderboards do |t|
      t.integer :user_id, null: false 
      t.string :game_name, null: false
      t.float :score

      t.timestamps
    end
  end
end
