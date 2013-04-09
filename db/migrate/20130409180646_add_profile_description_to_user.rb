class AddProfileDescriptionToUser < ActiveRecord::Migration
  def change
    add_column :users, :profile_description_id, :integer
  end
end
