class AddDeviceInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :devices, :string, array: true
  end
end
