class ConvertDeviseUsersTableToScratchAuthTable < ActiveRecord::Migration
  def change
    remove_index :users, :reset_password_token
    change_table :users do |t|

      ## Remove the Devise specific columns
      ## Database authenticatable
      t.remove :encrypted_password
      ## Recoverable
      t.remove :reset_password_token, :reset_password_sent_at
      ## Rememberable
      t.remove :remember_created_at
      ## Trackable
      t.remove :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip

      ## Remove our older columns to be consistent and redefine them:
      t.remove :admin, :guest

      ## Create our new "Authentication From Scratch" columns
      t.string :password_digest, :null => false, :default => ""
      t.boolean :admin, :null => false, :default => false
      t.boolean :guest, :null => false, :default => false
    end
  end
end
