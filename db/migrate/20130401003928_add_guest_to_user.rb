class AddGuestToUser < ActiveRecord::Migration
  def change
    add_column :users, :guest, :Boolean
  end
end
