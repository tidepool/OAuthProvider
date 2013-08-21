class AddAdditionalToUser < ActiveRecord::Migration
  def change
    add_column :users, :ios_device_token, :string
    add_column :users, :android_device_token, :string
    add_column :users, :is_dob_by_age, :boolean
  end
end
