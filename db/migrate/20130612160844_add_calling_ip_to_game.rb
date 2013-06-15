class AddCallingIpToGame < ActiveRecord::Migration
  def change
    add_column :games, :calling_ip, :string
  end
end
