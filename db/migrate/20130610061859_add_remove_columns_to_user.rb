class AddRemoveColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :calling_ip, :string
    add_column :users, :handedness, :string
    add_column :users, :orientation, :string

    remove_column :users, :profile_description_id
  end
end
