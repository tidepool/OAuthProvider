class CreateInvitedUsers < ActiveRecord::Migration
  def change
    create_table :invited_users do |t|
      t.integer :inviter_id, null: false
      t.string  :invited_email, null:false
      t.timestamps
    end

    add_index :invited_users, :inviter_id
    add_index :invited_users, :invited_email
  end
end
