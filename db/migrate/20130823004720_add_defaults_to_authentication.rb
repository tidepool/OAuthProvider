class AddDefaultsToAuthentication < ActiveRecord::Migration
  def change
    change_column_default :authentications, :sync_status, 'not_synchronized'

    add_index :authentications, :sync_status
  end
end
