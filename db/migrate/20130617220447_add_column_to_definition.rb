class AddColumnToDefinition < ActiveRecord::Migration
  def change
    add_column :definitions, :unique_name, :string

    add_index :definitions, :unique_name, :unique => true
  end
end
