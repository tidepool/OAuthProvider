class AddTypeToResults < ActiveRecord::Migration
  def change
    add_column :results, :type, :string

    remove_index :results, :result_type
    add_index :results, :type

    remove_column :results, :result_type
  end
end
