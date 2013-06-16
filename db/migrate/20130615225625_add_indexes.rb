class AddIndexes < ActiveRecord::Migration
  def change
    add_index :authentications, :user_id
    add_index :authentications, :provider
    add_index :authentications, :uid

    add_index :games, :user_id
    
    add_index :profile_descriptions, :big5_dimension
    add_index :profile_descriptions, :holland6_dimension

  end
end
