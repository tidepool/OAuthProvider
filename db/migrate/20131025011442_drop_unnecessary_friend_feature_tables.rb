class DropUnnecessaryFriendFeatureTables < ActiveRecord::Migration
  def change
    remove_index :invitations, :user_id
    remove_index :invited_users, :inviter_id
    remove_index :invited_users, :invited_email

    drop_table :invitations
    drop_table :invited_users

    add_index :friendships, :friend_id
    remove_index :friendships, :status
    remove_column :friendships, :status
  end
end
