class AddResultViewToDefinition < ActiveRecord::Migration
  def change
    add_column :definitions, :result_view, :string
    remove_column :definitions, :experiment
  end
end
