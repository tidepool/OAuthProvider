class ChangeAndRemoveColumnsForDefinitions < ActiveRecord::Migration
  def change
    remove_column :definitions, :recipe_name
    rename_column :definitions, :score_names, :recipe_names
  end
end
