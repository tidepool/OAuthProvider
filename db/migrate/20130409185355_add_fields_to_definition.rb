class AddFieldsToDefinition < ActiveRecord::Migration
  def change
    add_column :definitions, :score_names, :text
    add_column :definitions, :calculates, :text
  end
end
