class RemoveColumnsFromResults < ActiveRecord::Migration
  def change
    # remove_column :results, :profile_description_id
    add_column :results, :type, :string
  end
end
