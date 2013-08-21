class RenameResultViewToRecipeNameInDefinitions < ActiveRecord::Migration
  def change
    rename_column :definitions, :result_view, :recipe_name
    rename_column :definitions, :calculates, :persist_as_results   
    remove_column :definitions, :icon
    remove_column :definitions, :end_remarks
  end
end
