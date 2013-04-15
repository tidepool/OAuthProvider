class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
      t.string :oauth_token
      t.datetime :oauth_expires_at

      # Superset of all data we can get from auth providers
      t.string :email
      t.string :name
      t.string :display_name
      t.string :description

      # Location
      t.string :city
      t.string :state
      t.string :country
      t.string :timezone
      t.string :locale

      # Image (avatar)
      t.string :image

      # Personal info
      t.string :gender
      t.date :date_of_birth

      # Provider only
      t.date :member_since

      t.timestamps
    end
  end
end
