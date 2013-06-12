class RemoveCallingIpFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :calling_ip
  end
end
