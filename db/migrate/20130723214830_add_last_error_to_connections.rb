class AddLastErrorToConnections < ActiveRecord::Migration
  def change
    add_column :authentications, :last_error, :text
  end
end
