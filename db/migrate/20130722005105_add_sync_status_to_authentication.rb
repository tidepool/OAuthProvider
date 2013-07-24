class AddSyncStatusToAuthentication < ActiveRecord::Migration
  def change
    add_column :authentications, :sync_status, :string
  end
end
