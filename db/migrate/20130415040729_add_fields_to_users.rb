class AddFieldsToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
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

    end
  end
end
