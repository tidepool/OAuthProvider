class AddRemoveColumnsFromResults < ActiveRecord::Migration
  def change
    remove_column :results, :profile_description_id
    remove_column :results, :scores
    # add_column :results, :type, :string
  end
end
