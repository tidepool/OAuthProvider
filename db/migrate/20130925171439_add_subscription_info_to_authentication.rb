class AddSubscriptionInfoToAuthentication < ActiveRecord::Migration
  def change
    add_column :authentications, :subscription_info, :string
  end
end
