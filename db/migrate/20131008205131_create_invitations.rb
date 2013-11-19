class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :user_id, null: false
      t.text    :email_invite_list
      t.timestamps
    end

    add_index :invitations, :user_id
  end
end
