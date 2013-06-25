class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :education, :string
    add_column :users, :referred_by, :string

    add_index :users, :referred_by
  end
end
