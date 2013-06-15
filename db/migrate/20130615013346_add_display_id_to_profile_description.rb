class AddDisplayIdToProfileDescription < ActiveRecord::Migration
  def change
    add_column :profile_descriptions, :display_id, :string
  end
end
