class AddFacebookSpecificFieldsToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :oauth_refresh_at, :datetime
    add_column :authentications, :expires, :boolean
    add_column :authentications, :permissions, :text
  end
end
