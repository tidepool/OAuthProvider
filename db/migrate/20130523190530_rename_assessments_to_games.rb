class RenameAssessmentsToGames < ActiveRecord::Migration
  def change
    rename_table :assessments, :games
    remove_index :results, :assessment_id
    rename_column :results, :assessment_id, :game_id
    add_index :results, :game_id, :unique => true
  end
end
