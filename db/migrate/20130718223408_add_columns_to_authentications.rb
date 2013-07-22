class AddColumnsToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :oauth_secret, :string
    add_column :authentications, :is_activated, :boolean
    add_column :authentications, :last_accessed, :datetime
    add_column :authentications, :last_synchronized, :hstore
    add_column :authentications, :profile, :hstore
  end
end
