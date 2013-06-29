class AddColumnsToResults < ActiveRecord::Migration
  def change
    add_column :results, :result_type, :string
    add_column :results, :score, :hstore 
    add_column :results, :calculations, :text
    add_column :results, :user_id, :integer

    add_index :results, :user_id
    add_index :results, :result_type
    add_index :results, :score, using: :gin
    remove_index :results, :game_id # Prior one was unique, cannot be anymore.
    add_index :results, :game_id
  end
end
