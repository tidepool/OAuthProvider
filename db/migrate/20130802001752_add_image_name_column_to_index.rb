class AddImageNameColumnToIndex < ActiveRecord::Migration
  def change
    add_index :images, :name
  end
end
