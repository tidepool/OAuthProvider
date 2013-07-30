class RemoveExpiresAtFromAuthentications < ActiveRecord::Migration
  def change
    remove_column :authentications, :expires_at
  end
end
