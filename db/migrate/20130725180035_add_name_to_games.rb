class AddNameToGames < ActiveRecord::Migration
  def change
    add_column :games, :name, :string

    add_index :games, :name
  end
end
