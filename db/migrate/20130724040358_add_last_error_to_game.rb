class AddLastErrorToGame < ActiveRecord::Migration
  def change
    add_column :games, :last_error, :text
  end
end
